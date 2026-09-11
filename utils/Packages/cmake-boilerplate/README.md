

# GreenSocs Build and make system

# How to build
> 
> This project may be built using cmake
> ```bash
> cmake -B build;pushd build; make -j; popd
> ```
> 
cmake may ask for your git.greensocs.com credentials (see below for advice about passwords)

## cmake version
cmake version 3.14 or newer is required. This can be downloaded and used as follows
```bash
 curl -L https://github.com/Kitware/CMake/releases/download/v3.20.0-rc4/cmake-3.20.0-rc4-linux-x86_64.tar.gz | tar -zxf -
 ./cmake-3.20.0-rc4-linux-x86_64/bin/cmake
```
 


## details

This project uses CPM https://github.com/cpm-cmake/CPM.cmake in order to find, and/or download missing components. In order to find locally installed SystemC, you may use the standards SystemC environment variables: `SYSTEMC_HOME` and `CCI_HOME`.
CPM will use the standard CMAKE `find_package` mechanism to find installed packages https://cmake.org/cmake/help/latest/command/find_package.html
To specify a specific package location use `<package>_ROOT`
CPM will also search along the CMAKE_MODULE_PATH

Sometimes it is convenient to have your own sources used, in this case, use the `CPM_<package>_SOURCE_DIR`.
Hence you may wish to use your own copy of SystemC CCI 
```bash
cmake -B build -DCPM_SystemCCCI_SOURCE=/path/to/your/cci/source`
```

It may also be convenient to have all the source files downloaded, you may do this by running 
```bash
cmake -B build -DCPM_SOURCE_CACHE=`pwd`/Packages
```
This will populate the directory `Packages` Note that the cmake file system will automatically use the directory called `Packages` as source, if it exists.

NB, CMake holds a cache of compiled modules in ~/.cmake/ Sometimes this can confuse builds. If you seem to be picking up the wrong version of a module, then it may be in this cache. It is perfectly safe to delete it.

### Common CMake options
`CMAKE_INSTALL_PREFIX` : Install directory for the package and binaries.
`CMAKE_BUILD_TYPE`     : DEBUG or RELEASE

By default the value of the `CMAKE_INSTALL_PREFIX` variable is the `install/` directory located in the top level directory.

The library assumes the use of C++14, and is compatible with SystemC versions from SystemC 2.3.1a.


For a reference docker please use the following script from the top level of the Virtual Platform:
```bash
curl --header 'PRIVATE-TOKEN: W1Z9U8S_5BUEX1_Y29iS' 'https://git.greensocs.com/api/v4/projects/65/repository/files/docker_vp.sh/raw?ref=master' -o docker_vp.sh
chmod +x ./docker_vp.sh
./docker_vp.sh
> cmake -B build;cd build; make -j
```

### passwords for git.greensocs.com
To avoid using passwords for git.greensocs.com please add a ssh key to your git account. You may also use a key-chain manager. As a last resort, the following script will populate ~/.git-credentials  with your username and password (in plain text)
```bash
git config --global credential.helper store
```

## More documentation

More documentation, including doxygen generated API documentation can be found in the `/docs` directory.

[//]: # (SECTION 100)

----------------
# Internal details, how to organize a repository to use this system

### Internal tricks

If you have a checked out module that you would like to use the source, then use
-DCPM_<dep>_SOURCE=/path/to/dep

To overwrite the boilerplate itself, set gs-cmake_SOURCE_DIR

If you want to avoid downloading all the components of the project every time you build it, there is a CPM feature which provides a source cache that can help:

This feature will automatically be enabled if you include a /Packages directory at the top level of your project, or if one is provided for you. 

If you would like to use a different cache, you may do so by manually setting the path when building the project:
`-DCPM_SOURCE_CACHE=/path/to/your/deps`

If the cache directory doesn't exist yet it will be created and filled. If if already exists, packages will be used from the cache during build.

> A special target is set up to update documentation
> `make updatedocs`
> Run this from within a build directory : NB this will update the top level README.md, as well as generating documentation in /doc/ from doxygen, AND including docs from all dependencies.

**Writing README.md files**

*DO NOT TOUCH THE README.md FILE IT'S GENERATED FROM THE README-local.md FILE*

In order for README-local.md files to be correctly processed they should follow the following scheme.
The main part of the readme, with no 'section' identifiers will be copied to projects using this library, after their own main body.
Please take care to keep the text in these parts generic and refer to the component by name.

Subsiquent sections are identified by comments in the form :
> ` [//]: # (SECTION [0-9]+) `

Hence `[//]: # (SECTION 100)`

Sections are compiled together in order. Any section numbered 100 or greater is excluded from being included in a compiled README (and will only be found in the local documentation)

The following scheme is suggested:
- *Section 0* The base section (which need not be labeled) Critical information about the nature of the component.
- *Section 10* Information about building and using the component as part of an executable (dependencies, parameters...)
- *Section 50* Information about the use of the component in user source code (API, functionality...)
- *Section 100* Design and implementation information.


## How to use

The minimal cmake file should look like this:


```
cmake_minimum_required(VERSION 3.14)
project(yourProjectName  VERSION 1.0  LANGUAGES CXX)
##############################################
# ----- fetch GreenSocs cmake BOILERPLATE
##############################################
if (NOT gs-cmake_SOURCE_DIR)
   include(FetchContent)
   FetchContent_Declare(gs-cmake
      GIT_REPOSITORY https://git.greensocs.com/greensocs/cmake-boilerplate.git
      GIT_TAG master
   )
   FetchContent_MakeAvailable(gs-cmake)
endif()
include(${gs-cmake_SOURCE_DIR}/cmake/gs-boilerplate.cmake)
##############################################
```

Some macro's are included to help

`gs_systemc()`
    include default GreenSocs SystemC

`gs_addpackage(name)`
    Add's name as a package using CPM. This will add the package from the greensocs git, using the same branch as the current projects branch.
    The git used will be 'guessed' from the git repository - remember to make sure your current branch tracks an upstream repository.
    This can be over-ruled by the variable `GREENSOCS_GIT` which can be set to force a specific git repository

<!-- `gs_enable_testing()`
    Include the /test directory for tests (NB you should always use the name /test, no other option is given) -->

`gs_export()`
    Setup the project to export correctly - this macro should _ALWAYS_ be used. 
    NB this macro does NOT handle the include configutation.
    
A project should also include a .gitlab-ci.yml file with the  entry:
```
include:
  - remote: 'https://git.greensocs.com/greensocs/cmake-boilerplate/-/raw/master/gitlab-ci-template.yml'
```
### CPM Package Lock
If you want an even more specific build without modifying the original CMakeLists.txt there is a feature in CMake called CPM lock package.
To use it you first need to build the project with your specifications. (For example by modifying the `GREENSOCS_GIT` and `GIT_BRANCH` variables mentioned above)
```bash
cmake -Bbuild [OPTIONS]
```
And then create a file to make the necessary changes to make another build with the chosen specifications.
```bash
cmake --build build --target cpm-update-package-lock
```
After this a file called `package-lock.cmake` will be created in the top level of your directory.
There you will find your various dependencies and how they were retrieved. (Git or local)

For dependencies retrieved by git repo you just have to change the URL or TAG if you want another branch.

Otherwise if you want to use a local dependency you have an example below:
```cmake
CPMDeclarePackage(library
  NAME library
  SOURCE_DIR /path/to/your/library
)
```
Once all your changes are complete you can now recompile your project with :
```bash
cmake -Bbuild [OPTIONS]
```
If you want to do another specific build, edit again the file `package-lock.cmake` and recompile.

You can use your own lock file package by using the option:
```bash
-DPKG_LOCK=/path/to/your/package/lock/file
```

If this doesn't work, you may need to remove the cache from your build directory:
```bash
rm build/CMakeCache.txt
```

[//]: # (PROCESSED BY doc_merge.pl)

