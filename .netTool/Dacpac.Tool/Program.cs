using System;
using System.Linq;
using System.Threading;
using Microsoft.Extensions.Configuration;
using Microsoft.SqlServer.Dac;

namespace Dacpac.Tool
{
    class Program
    {
        private static IConfiguration _configuration;

        private const string EnvPrefix = "dac__";


        public const string DacDeployOptionsKey = "DacDeployOptions";


        static void Main(string[] args)
        {
            if (args == null || !args.Any())
            {
                Main(Console.ReadLine().Split(" "));
                return;
            }
            ConfigurationBuild(args);
            var option = _configuration.GetSection(DacDeployOptionsKey).Get<DacDeployOptions>() ?? new DacDeployOptions();
            var dacPackageOptions = _configuration.GetSection("DacPackage").Get<DacPackageOptions>() ?? new DacPackageOptions();

            var package = dacPackageOptions.FindDacPackage();
            foreach (var connection in dacPackageOptions.Connections)
            {
                var dacService = new DacServices(connection.Value);
                dacService.ProgressChanged += DacService_ProgressChanged;
                dacService.Deploy(package, connection.Key, true, option);
            }

            Console.WriteLine("Finished!");
            Thread.Sleep(2000);
        }

        private static void DacService_ProgressChanged(object sender, DacProgressEventArgs e)
        {
            System.Diagnostics.Trace.TraceInformation(e.ToString());
        }

        static void ConfigurationBuild(string[] args)
        {
            _configuration = new Microsoft.Extensions.Configuration.ConfigurationBuilder()
                  .AddEnvironmentVariables(a => { a.Prefix = EnvPrefix; })
                  .AddCommandLine(args)
                  .Build();


        }

    }

}
