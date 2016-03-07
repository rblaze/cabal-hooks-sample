import Distribution.ModuleName (fromString)
import Distribution.PackageDescription
import Distribution.Simple
import Distribution.Simple.BuildPaths
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Program
import Distribution.Simple.Setup
import Distribution.Simple.Utils
import Distribution.Verbosity
import Control.Applicative
import Control.Monad
import Data.List
import System.Directory
import System.FilePath

main = defaultMainWithHooks $ simpleUserHooks
    { hookedPrograms = [simpleProgram "codegen.sh"]
    , postConf = runCodegen
    , buildHook = addModulesBuild
    , copyHook = addModulesCopy
    , regHook = addModulesReg
    , instHook = addModulesInstall
}

addModules :: PackageDescription -> LocalBuildInfo -> IO PackageDescription
addModules pd0 lbi = do
    let outPath = autogenModulesDir lbi
    let filelist = outPath </> "filelist"
    modules <- fmap lines $ readFile filelist
    let hbi = (Just $ emptyBuildInfo{ otherModules = map fromString modules }, [])
    return $ updatePackageDescription hbi pd0

addModulesBuild :: PackageDescription -> LocalBuildInfo -> UserHooks -> BuildFlags -> IO ()
addModulesBuild pd0 lbi hooks flags = do
    print "build hook"
    pd <- addModules pd0 lbi
    -- run default hook
    buildHook simpleUserHooks pd lbi hooks flags
    print "build finished"

addModulesReg :: PackageDescription -> LocalBuildInfo -> UserHooks -> RegisterFlags -> IO ()
addModulesReg pd0 lbi hooks flags = do
    print "reg hook"
    pd <- addModules pd0 lbi
    -- run default hook
    regHook simpleUserHooks pd lbi hooks flags
    print "reg finished"

addModulesCopy :: PackageDescription -> LocalBuildInfo -> UserHooks -> CopyFlags -> IO ()
addModulesCopy pd0 lbi hooks flags = do
    print "copy hook"
    pd <- addModules pd0 lbi
    -- run default hook
    copyHook simpleUserHooks pd lbi hooks flags
    print "copy finished"

addModulesInstall :: PackageDescription -> LocalBuildInfo -> UserHooks -> InstallFlags -> IO ()
addModulesInstall pd0 lbi hooks flags = do
    print "install hook"
    pd <- addModules pd0 lbi
    -- run default hook
    instHook simpleUserHooks pd lbi hooks flags
    print "install finished"

runCodegen :: Args -> ConfigFlags -> PackageDescription -> LocalBuildInfo -> IO ()
runCodegen args conf pd lbi = do
    let verbosity = fromFlagOrDefault normal $ configVerbosity conf
    (codegen, _) <- requireProgram verbosity (simpleProgram "codegen.sh") (configPrograms conf)
    let outPath = autogenModulesDir lbi

    runProgram verbosity codegen [outPath]

    -- run default hook
    postConf simpleUserHooks args conf pd lbi
