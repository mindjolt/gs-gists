Using the Unity SDK Tools
=========================

The Unity SDK tools allows for the creation of stand-alone unity SDK projects.
The system allows for full dependency management among other Jam City unity
projects as well as third-party libraries. Each project is a self-contained
set of C# and native (when applicable) source code along with a full suite of unit
tests. Projects built with this tool set will automatically become
available in the Jam City Package Manager in the unity editor.

## Export your GitHub Personal Access Token and User

```bash
export GH_PAT=<YOUR_GITHUB_PAT>
export GH_USER=<YOUR_GITHUB_USERNAME>
```

## Environment Setup

To begin, you need to first ensure your work environment is set up with the
appropriate tools. To do this, you need to execute the following:

```bash
bash -c "$(curl --silent "https://raw.githubusercontent.com/mindjolt/gs-gists/master/sdk-dev-setup.sh")"
```

This will do the following:

* Install [HomeBrew](https://brew.sh/) (if not already installed).
* Update local HomeBrew packages.
* Install [sbt](https://www.scala-sbt.org/) (this is the tool that drives the build process).
* Install mono, dotnet, npm and nuget.


## Creating a Project

To create a new, empty project, run the following in the directory in which
you want the project folder created:

```bash
sbt new mindjolt/unity-sdk.g8
```

Follow the prompts to create your project.


## Anatomy of a Project

The following are the important files and directories for any project:

| Name                     | Description                                                                                                                                                                                                              |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| build.sbt                | Drives the project build process, dependencies etc.                                                                                                                                                                      |
| README.md                | Basic README file use to describe how to build the project. Details about the functionality of the project are in `doc/Unity.md`. You generally don't need to edit this unless you have some special build requirements. |
| doc/Unity.md             | User-facing documentation about how to use whatever the project provides.                                                                                                                                                |
| CHANGELOG.md               | Standard change log that *must* be updated with each release.                                                                                                                                                            |
| .gitignore               | A standard .gitignore file with most of the useful stuff already present.                                                                                                                                                |
| src/main/csharp          | The directory that should contain all of your csharp source code.                                                                                                                                                        |
| src/test/csharp          | The directory that should contain all of you unit tests.                                                                                                                                                                 |
| src/main/ios             | Optional directory that should contain any native iOS code that will be built with xcode.                                                                                                                                |
| src/main/android         | Optional directory that should contain any native android java code or jars.                                                                                                                                             |
| src/main/webgl           | Optional directory that should contain any JS or other webgl-specific files.                                                                                                                                             |
| project/plugins.sbt      | Contains setup for the sbt build process. You generally never need to edit this.                                                                                                                                         |
| project/build.properties | Defines the sbt version to use. You generally don't need to edit this.                                                                                                                                                   |


There are additionally some transient files and directories you should be aware of.

**None of the following should _ever_ be manually modified or checked in to git!**


| Name                                  | Description                                                                                                                                                            |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| target                                | This directory will contain all build artifacts and interim build files for the project. It is always safe to remove this directory as it is recreated for each build. |
| project/target                        | Similar to `target` but for bootstrapping the sbt system.                                                                                                              |
| project/project                       | Similar to `target` but for bootstrapping the sbt system.                                                                                                              |
| src/main/csharp/Directory.Build.props | This is an automatically maintained file that makes the msbuild process work and makes tools like Rider and Visual Studio recognize the project.                       |
| src/main/csharp/*.csproj              | Any *.csproj file is an automatically maintained file that makes the msbuild process work and makes tools like Rider and Visual Studio recognize the project.          |
| src/test/csharp/Directory.Build.props | This is an automatically maintained file that makes the msbuild process work and makes tools like Rider and Visual Studio recognize the project.                       |
| src/test/csharp/*.csproj              | Any *.cproj is an automatically maintained file that makes the msbuild process work and makes tools like Rider and Visual Studio recognize the project.                |
| src/main/package.json                 | This is a standard npm-style package.json that is automatically generated during the build process.                                                                    |
| src/main/csharp/Editor/SymbolSetup.cs | This is an automatically generated file that provides some features in the Unity Editor.                                                                               |
| src/main/csharp/JamCityBuildInfo.cs   | This is automatically generated and contains runtime-accessible build information.                                                                                     |
| *.sln                                 | Any *.sln is an automatically maintained file that makes the msbuild process work and makes tools like Rider and Visual Studio recognize the project.                  |



## The build.sbt file

The build.sbt file directs the sbt build process. In addition to the somewhat
common portions of the build.sbt, we have our own additional features that enable
dependency management and the csharp build process.

### The Basics

The first section of the build sbt contains information about the project:

```sbt
organization := "com.jamcity.notification"
name := "JamCity.NotificationSdk"
version := "1.0.0-SNAPSHOT"
````

The `organization` and `name`, once set, are not changed and are set when you
set up the project. The `version` should be changed for each release following
the SemVer 2 methodology. See [Versioning](#versioning) for more information.

The next section is the `UnityProject` section. It looks something like this:

```sbt
unityProject := unityProject.value.copy(
  displayName = Some("Jam City Notification SDK"),
  dotnetTarget = DotnetTarget.Net35,
  csharpVersion = CSharpVersion.CS40,
  files = Map(
    "CHANGES.md" -> "CHANGELOG.md",
    "doc/Unity.md" -> "Documentation/Unity.md",
  ),

  dependencies = Seq(
    "JamCity.CommonSdk" ^ ">= 1.0.0 < 2.0.0",
    "Unity" ^ ">= 2018.3.0" ^ DependencyScope.System,
    "nunit" ^ "3.11.0" ^ DependencyScope.Test,
    "NSubstitute" ^ "2.0.3" ^ DependencyScope.Test
  )
)
```

Generally speaking, you will only need to modify `dependencies` in the above.
Note that we default to using NET 4.5 and C# 7.0 to be as compatible as possible
with different versions of unity.

The `depdendencies` describes other projects and libraries that this project depends on.
Dependencies can either be other Jam City SDK project ("JamCity.CommonSdk" in the above example),
some internally defined libraries ("Unity" in the above example) and nuget.org
packages that can be used for testing and other select purposes.

Each dependency is a package name followed by a version specification followed
optionally by a `DependencyScope` modifier. The version specification can
be either a specific version or a range specification as described [here](https://docs.npmjs.com/misc/semver).

The optional `DependencyScope` can have one of the following values:

* `DependencyScope.Compile` - Indicates the dependency is required at both compile and runtime. This is the default.
* `DependencyScope.Optional` - A dependency which is required at compile time but may be optionally present at runtime.
* `DependencyScope.Provided` - A dependency which is required at compile by but is expected to be separately installed at runtime.
* `DependencyScope.System` - Special case of a provided dependency, used for including Unity libraries to compile against.
* `DependencyScope.Test` - Dependencies that are only present during unit testing. These can be nuget.org dependencies.

For example, if you needed to include `Json.Net` in your project, the correct way to
add that would be to add a dependency like this:

    "Json.Net.Unity3D" ^ "9.0.1" ^ DependencyScope.Provided


### Compiler Symbols

You can add compiler symbols to use during the normal build process as well
as different sets of compiler symbols to use for unit testing.

Do the following to add compiler symbols to all builds, including test builds:

    dotnetDirectives := "SYMBOL1;SYMBOL2"

The value is a semi-colon separated list of symbols to use.

To define symbols to use during unit testing only:

    dotnetTestDirectives := Seq("UNITY_IOS", "UNITY_ANDROID")

This is a sequence of semi-colon separated symbols. Each member of the sequence
will cause all unit tests to be run with the symbols defined, plus any
defined in `dotnetDirectives`. For the above, unit tests would be run twice,
first with symbols "SYMBOL1", "SYMBOL2" and "UNITY_IOS" and then
with symbols "SYMBOL1", "SYMBOL2" and "UNITY_ANDROD".


### Compiler Warnings

You can choose to have certain compiler warning treated as errors.
To do this, set:

    dotnetWarningsAsErrors := Seq("CS0414", "CS0618")

The above sequence of Strings would treat warnings CS0414 and CS0618 as errors.


#### Running Unit Test for different .NET or C# versions

It is occasionally necessary or simply useful to be able to author unit test
using more modern .NET or C# language features. You can change these settings
for testing in your project by overriding the `UnityProject` in sbt's `Test`
scope:

```sbt
unityProject in Test := unityProject.value.copy(
  csharpVersion = CSharpVersion.CS70,
  dotnetTarget = DotnetTarget.Net40
)
```

These settings *only* affect unit tests. The main source will still be built against
the settings in the main 'UnityProject'.


## iOS Native Code

To add native iOS code to you project, include that source in the
`src/main/ios` directory. This code will be included in the packaging
of the SDK and get automatically built into the target game.


## Android Native Code

To add native android code to you project, include either java source or
jar files in the `src/main/android` directory. If you are including java source,
the `src/main/android` directory should be the root of you class structure.
If you include jar files, put them in the `src/main/android` directory.

### AndroidManifest.xml

If your SDK requires an AndroidManifest.xml, put that directly into
the `src/main/android` directory. When the SDK is installed in a game,
the file will be moved to the proper location such that it gets merged into
the game's AndroidManifest.xml.

### project.properties

If your SDK requires a custom android `project.properties`, add it directly
to the `src/main/android` directory. When the SDK is installed in a game,
the file will be moved to the proper location.


## sbt commands

The follow sbt commands are most commonly used when developing unity SDKs.

| Command           | Description                                                                                                                                                                            |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `sbt clean`       | Removes all compiler artifacts                                                                                                                                                         |
| `sbt compile`     | Compiles all of the csharp source, reporting an errors. If there are any android java files, they will be compiled as well.                                                            |
| `sbt test`        | Runs all unit tests                                                                                                                                                                    |
| `sbt packagUnity` | Creates a unity package suitable for deploying to unity. The resulting package can be found in the directory `target/<name>` where <name> is the `name' sbt property in the build.sbt. |


On occasion, you may need to completely wipe the project's build artifacts when, for example, a
new version of the sbt unity plugin is available. To do this, you should remove the following
directories and all of their contents from your project:

    target
    project/target
    project/project


## Versioning

All projects created with this set of tools must follow the rules set out in
[Semantic Versioning 2[(https://semver.org/) when setting versions.

To that end, all versions must include MAJOR.MINOR.PATCH, minimally,
in the version string. When incrementing versions, follow the rules
defined in the semver.org website:

Given a version number MAJOR.MINOR.PATCH, increment the:

- MAJOR version when you make incompatible API changes,
- MINOR version when you add functionality in a backwards compatible manner, and
- PATCH version when you make backwards compatible bug fixes.

You can also us the "+" modifier to add other release qualifiers, but these
should be used rarely.

We also use the "SNAPSHOT" convention for development builds. Any version
string with "-SNAPSHOT" appended to it is considered a SNAPSHOT build.


