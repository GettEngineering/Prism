<p align="center">
<img src="Assets/gh/logo.jpg" alt="Prism: Design System Code Generator logo" title="Prism: Design System Code Generator logo" />
<br />
<a href="https://actions-badge.atrox.dev/GettEngineering/Prism/goto" target="_blank" alt="Build Status" title="Build Status"><img src="https://github.com/GettEngineering/Prism/workflows/Prism/badge.svg?branch=main" alt="Build Status" title="Build Status"></a>
<a href="https://codecov.io/gh/GettEngineering/Prism" target="_blank" alt="Code Coverage for Prism on codecov" title="Code Coverage for Prism on codecov"><img src="https://codecov.io/gh/GettEngineering/Prism/branch/main/graph/badge.svg" alt="Code Coverage for Prism on codecov" title="Code Coverage for Prism on codecov"/></a>
<img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-%23989898" />
<a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" alt="Swift Package Manager Support" /></a>
</p>

Prism is a Design System code generator developed by the team at Gett 🚕.

Synchronizing design teams with engineering teams is a huge challenge.

As teams scale, new growing pains start around how to properly align colors, text styles, spacing and other design details between teams, in a uniform way, from a single source of truth.

Prism was built to solve this very problem! It takes either Zeplin project/styleguide or a set of Figma files as input, and generates any output code you want from these based on a set of templates in your project, resulting in cross-platform code that is always synchronized from a single source-of-truth (Your design files).

Prism is especially useful when used in your CI/CD process to remove the friction of design handoff and review, and making sure all of your teams are properly synchronized in regards to naming, values, and more.

## Getting Started

### 📹 Videos

* [A 60 seconds introduction to Prism](https://www.youtube.com/watch?v=MNcAAUji-YY)
* [Design a Design System @ Swift Heroes, Italy](https://www.youtube.com/watch?v=UFyx7EtbcMU) (25 minutes)

### 🌈 Getting Prism

There are five options to install prism: 

1. **Install with [Homebrew](https://brew.sh)**: `brew install GettEngineering/tap/prism`
1. **Install using [Mint](https://github.com/yonaskolb/Mint)**: `mint install GettEngineering/Prism`
1. **Build from source**: `make install`
1. **Run directly with SPM**: `swift run prism generate` 
1. [**Running on Windows**](#running-on-windows-experimental) _(experimental)_


### 🔑 Getting a Provider API Token

#### Figma

To use Prism with Figma, you'll need to generate a Personal Access Token (JWT) to Figma's API by going to [https://www.figma.com](https://www.figma.com). Then, go the **Settings** section under your profile:

![Finding the Settings section in Figma](Assets/gh/figma-pat1.png "Finding the Settings section in Figma")

Scroll to the bottom of the **Account** tab, find the **Personal access tokens** section, and create your new token:

![Generating a Figma Personal Access Token](Assets/gh/figma-pat2.png "Generating a Figma Personal Access Token")

You'll need to expose this token to run the `prism` CLI tool. Make sure you have a `FIGMA_TOKEN` environment variable with your token configured. 

When running `prism` in a CI environemnt, we recommend adding `FIGMA_TOKEN` as an Environment Secret.

When using `prism` locally or bootstrapping your project for the first time, you can simply run `export FIGMA_TOKEN='zeplin_personal_token'` before running `prism` locally.

#### Zeplin
To use Prism with Zeplin, you'll need to generate a Personal Access Token (JWT) to Zeplin's API by going to [https://app.zeplin.io/profile/developer](https://app.zeplin.io/profile/developer) and click the **Create new token** button in the **Personal access tokens** section:

![Generating a Zeplin Personal Access Token](Assets/gh/zeplin-pat.png "Generating a Zeplin Personal Access Token")

You'll need to expose this token to run the `prism` CLI tool. Make sure you have a `ZEPLIN_TOKEN` environment variable with your token configured. 

When running `prism` in a CI environemnt, we recommend adding `ZEPLIN_TOKEN` as an Environment Secret.

When using `prism` locally or bootstrapping your project for the first time, you can simply run `export ZEPLIN_TOKEN='zeplin_personal_token'` before running `prism` locally.

### 👢 Bootstrap Prism for your Project

Inside your project folder, run `prism init`. 

It will guide you through selecting a Zeplin project/styleguide, or a set of Figma files as source along with other useful information for proper code generation. Once `prism init` is successful, you'll find a new `.prism` folder with a `config.yml` file outlining your preferences.

### 🎨 Creating Templates

Prism uses templates with the `.prism` suffix located in your project's `.prism` folder. These Prism templates are basically plain text files — Prism doesn't really care what format or language you use, it can make _any kind of output_ as long as you can express it in a Prism template file.

Prism looks for something called [**Tokens**](Documentation/Tokens.md) inside your templates. These tokens follow the following format: `{{%token%}}`. You can find a couple of sample templates in the [Examples](https://github.com/gtforge/Prism/tree/main/Examples) folder.

Here are two short example of generating colors code for iOS and Android using Prism templates.

**Colors.swift.prism**:

![Color.swift iOS Prism Template](Assets/gh/Colors-iOS.gif "Color.swift iOS Prism Template")

**colors.xml.prism**:

![Color.swift Android Prism Template](Assets/gh/Colors-Android.gif "Color.swift Android Prism Template")

## Development

* Run `make` or `make install` to build a release binary of the `prism` CLI tool and install it to **/usr/local/bin**.
* Run `make build` to build a release binary of the `prism` CLI tool
* Run `make project` to create an Xcode project and start working.
* Run `make test` to run all tests.
* Run `make clean` to clear the generated Xcode project.
