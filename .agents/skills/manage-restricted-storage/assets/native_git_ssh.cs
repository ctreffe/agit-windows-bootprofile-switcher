// Repository-bound native Windows Git transport. Runs in the caller's sandbox.
// Compiled deployment, key and public host key live in ignored .codex/native-git/.
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

internal static class RepositoryNativeSsh
{
    private const string Repository = "__APPROVED_OWNER__/__APPROVED_REPOSITORY__.git";

    private static string Quote(string value)
    {
        // Every argument is a fixed literal, a validated Git argument, or a
        // generated file path ending in a filename (never a trailing slash).
        if (value.IndexOf('"') >= 0 || value.IndexOf('\r') >= 0 || value.IndexOf('\n') >= 0)
            throw new ArgumentException("Invalid native argument");
        return "\"" + value + "\"";
    }

    private static bool Allowed(string[] args)
    {
        int start = 0;
        if (args.Length == 4 && args[0] == "-o" && args[1] == "SendEnv=GIT_PROTOCOL") start = 2;
        if (args.Length != start + 2 || args[start] != "git@github.com") return false;
        string command = args[start + 1];
        return command == "git-upload-pack '" + Repository + "'" ||
               command == "git-receive-pack '" + Repository + "'";
    }

    private static async Task Pump(Stream source, Stream destination)
    {
        byte[] buffer = new byte[8192];
        int count;
        while ((count = await source.ReadAsync(buffer, 0, buffer.Length)) != 0)
        {
            await destination.WriteAsync(buffer, 0, count);
            await destination.FlushAsync(); // Git negotiates before closing stdin.
        }
    }

    private static int Main(string[] args)
    {
        if (!Allowed(args))
        {
            Console.Error.WriteLine("NATIVE_GIT_SSH_ARGUMENTS_REJECTED");
            return 64;
        }
        try
        {
            string root = AppDomain.CurrentDomain.BaseDirectory;
            string key = Path.Combine(root, "id_ed25519");
            string hosts = Path.Combine(root, "known_hosts");
            if (!File.Exists(key) || !File.Exists(hosts))
            {
                Console.Error.WriteLine("NATIVE_GIT_SSH_SETUP_REQUIRED");
                return 78;
            }
            string[] options = {
                "-T", "-F", "none", "-o", "BatchMode=yes", "-o", "ConnectTimeout=15",
                "-o", "StrictHostKeyChecking=yes", "-o", "HostKeyAlgorithms=ssh-ed25519",
                "-o", "UserKnownHostsFile=" + hosts, "-o", "GlobalKnownHostsFile=NUL",
                "-o", "IdentityAgent=none", "-o", "IdentitiesOnly=yes", "-i", key
            };
            var info = new ProcessStartInfo(
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "System32", "OpenSSH", "ssh.exe"),
                String.Join(" ", options.Concat(args).Select(Quote).ToArray()));
            info.UseShellExecute = false;
            info.CreateNoWindow = true;
            info.RedirectStandardInput = true;
            info.RedirectStandardOutput = true;
            info.RedirectStandardError = true;
            using (var child = Process.Start(info))
            {
                var output = Pump(child.StandardOutput.BaseStream, Console.OpenStandardOutput());
                var error = Pump(child.StandardError.BaseStream, Console.OpenStandardError());
                var input = Pump(Console.OpenStandardInput(), child.StandardInput.BaseStream);
                input.ContinueWith(t => { try { child.StandardInput.Close(); } catch { } });
                if (!child.WaitForExit(120000))
                {
                    child.Kill();
                    Console.Error.WriteLine("NATIVE_GIT_SSH_TIMEOUT");
                    return 124;
                }
                if (!Task.WaitAll(new Task[] { output, error }, 5000))
                {
                    Console.Error.WriteLine("NATIVE_GIT_SSH_STREAM_TIMEOUT");
                    return 74;
                }
                return child.ExitCode;
            }
        }
        catch
        {
            Console.Error.WriteLine("NATIVE_GIT_SSH_EXECUTION_FAILED");
            return 70;
        }
    }
}
