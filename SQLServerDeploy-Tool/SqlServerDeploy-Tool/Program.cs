using System;
using System.IO;
using System.Linq;

namespace SqlServerDeploy_Tool
{

    class SqlDeployOption
    {

        ///<summary>Get or set boolean that specifies whether deployment will block due to platform compatibility.</summary>
        public bool AllowIncompatiblePlatform { get; set; } = true;

        ///<summary>Get or set boolean that specifies if deploy deve continue </summary>
        public bool BlockOnPossibleDataLoss { get; set; } = false;

        ///<summary>Get or set the time for await before timeout exception on deploy </summary>
        public int CommandTimeout { get; set; } = -1;

        ///<summary>Get or set boolean that specifies whether the existing database will be dropped and a new database 
        ///  created before proceeding with the actual deployment actions. Acquires single-user mode before dropping the existing database. 
        //True to drop and re-create the database; otherwise, false. Default is false. </summary>
        public bool CreateNewDatabase { get; set; } = false;

        ///<summary>Get or set boolean that specifies whether default values should be generated to populate NULL columns that are constrained to NOT NULL values.
        /// This is useful when needing to add a new NOT NULL column to an existing table with data.
        /// True if default values should be generated; otherwise false. Default is false.</summary>
        public bool GenerateSmartDefaults { get; set; } = true;

        ///<summary> Get or set boolean that specifies whether the plan verification phase is executed or not.
        /// True to perform plan verification; otherwise, false to skip it. Default is true.</summary>
        public bool VerifyDeployment { get; set; } = true;


        ///<summary>Get or set boolean that specifies whether the target collation will be used for identifier comparison.
        ///False to use the source collation; otherwise, true to use the target collation. Default is false.</summary>
        public bool CompareUsingTargetCollation { get; set; } = false;


        public static implicit operator Microsoft.SqlServer.Dac.DacDeployOptions(SqlDeployOption model)
        {


            var options = new Microsoft.SqlServer.Dac.DacDeployOptions()
            {
                BackupDatabaseBeforeChanges = true,
                AllowIncompatiblePlatform = model.AllowIncompatiblePlatform,
                BlockOnPossibleDataLoss = model.BlockOnPossibleDataLoss,
                CommandTimeout = model.CommandTimeout,
                CreateNewDatabase = model.CreateNewDatabase,
                GenerateSmartDefaults = model.GenerateSmartDefaults,
                VerifyDeployment = model.VerifyDeployment,
                CompareUsingTargetCollation = model.CompareUsingTargetCollation
            };
            return options;


        }
    }

    class Program
    {


        SqlDeployOption _option = new SqlDeployOption();

        static void Main(string[] args)
        {

            if (args == null || !args.Any())
            {
                Console.Error.WriteLine("No command send");
                return;
            }
            if (!args.Contains("--path"))
            {
                Console.Error.WriteLine("your need send dacpac path with paramters. Send --path");
                return;
            }
            var path = args[1];

            // D:\Gustavo\SourceCode\Intcom\BlueOpexDatabase\src\BlueOpex.Database.Schema\bin\Debug


            var package = FindDacPackage(path, null);

            Console.WriteLine("The file is load with success: {0}:{1}", package.Name, package.Version);


            Console.ReadKey();
        }

        static Microsoft.SqlServer.Dac.DacPackage FindDacPackage(string path, string fileNamePattern)
        {

            // Read the arguments sended by user
            if (string.IsNullOrWhiteSpace(path))
                path = Environment.CurrentDirectory;

            if (string.IsNullOrWhiteSpace(fileNamePattern))
                fileNamePattern = @"*.dacpac";

            if (!TryGetFiles(path, fileNamePattern, out string[] files) || !files.Any())
            {
                //TODO: write help
                Console.Error.WriteLine("No file find: {0}/{1}", path, fileNamePattern);
                return null;
            }
            else if (files.Length > 1)
            {
                //TODO: write help
                Console.Error.WriteLine("No can exists multiple files per pattern in directory: {0}/{1}", path, fileNamePattern);
                return null;
            }
            try
            {
                var packge = Microsoft.SqlServer.Dac.DacPackage.Load(files[0]);

                return packge;
                //TODO: write message
            }
            catch (TypeInitializationException typeInitializationException)
            {

                Console.Error.WriteLine("An error on read dacpac file: {0}/{1}", path, fileNamePattern);
                Console.Error.WriteLine(typeInitializationException);

            }
            catch (Exception exception)
            {
                Console.Error.WriteLine("An error on read dacpac file: {0}/{1}", path, fileNamePattern);
                Console.Error.WriteLine(exception);
            }

            return null;
        }




        void BuildProject()
        {

        }


        ///<summary>Run the command</summary>
        /// <summary>Gets the files match with sended file pattern</summary>
        /// <param name="path">The path.</param>
        /// <param name="filePattern">The file pattern.</param>
        /// <param name="files"></param>
        /// <returns></returns>
        private static bool TryGetFiles(string path, string filePattern, out string[] files)
        {
            files = new string[0];
            try
            {
                //TODO: write the throw code
                files = Directory.GetFiles(path, filePattern, new EnumerationOptions()
                {
                    IgnoreInaccessible = true,
                    MatchCasing = MatchCasing.CaseInsensitive,
                    RecurseSubdirectories = true
                })
                    .Distinct()
                    .ToArray();
                return true;
            }
            catch (UnauthorizedAccessException ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Error.WriteLine(ex.Message);
                return false;
            }
            catch (DirectoryNotFoundException ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Error.WriteLine(ex.Message);
                return false;
            }
            catch (IOException ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Error.WriteLine(ex.Message);
                return false;
            }
            finally
            {
                Console.ResetColor();
            }
        }
    }
}
