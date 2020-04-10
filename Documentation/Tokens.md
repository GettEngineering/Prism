<p align="center"><img src="../Assets/gh/tokens.png" alt="Prism Tokens" title="Prism Tokens" /></p>

Tokens are at the heart of Prism Templates. They let you represent placeholder locations in which you will use various pieces of information from your Zeplin Style Guide.

Tokens live inside your ***.prism** templates and follow the format `{{%TOKEN%}}`.

## Core Tokens

| Token            | Description                                                                                      |
|------------------|--------------------------------------------------------------------------------------------------|
| `FOR collection` | Iterate over asset collections, for example `FOR textStyle`, `FOR color`, or `FOR spacing`       |
| `END collection` | End iterating over asset collections, for example `END textStyle`, `END color`, or `END spacing` |
| `IF token`       | Confirm a token is available, for example `IF textStyle.alignment`                               |
| `ENDIF`          | Closes an `IF` block                                                                             |

## Color Tokens

| Token                      | Description                                                                       |
|----------------------------|-----------------------------------------------------------------------------------|
| `color.r`                  | The red component of the color (0-255)                                            |
| `color.g`                  | The green component of the color (0-255)                                          |
| `color.b`                  | The blue component of the color (0-255)                                           |
| `color.a`                  | The alpha component of the color (0.0-1.0)                                        |
| `color.rgb`                | The RGB value of this color (for example `#E22716`)                               |
| `color.argb`               | The ARGB value of this color (for example `#FFE22716`)                            |
| `color.identity`           | The identity/name of the color as defined on Zeplin                               |
| `color.identity.camelcase` | The identity/name of the color, formatted in camel case (e.g. `fancyLightBlue`)   |
| `color.identity.snakecase` | The identity/name of the color, formatted in snake case (e.g. `fancy_light_blue`) |

## Text Style Tokens

| Token                          | Description                                                                         |
|--------------------------------|-------------------------------------------------------------------------------------|
| `textStyle.fontName`           | The full Postscript font name of a TextStyle                                        |
| `textStyle.font`               | Alias of textStyle.fontName                                                         |
| `textStyle.fontSize`           | The text style's font size                                                          |
| `textStyle.alignment`          | The text style's alignment, if exists. Can be left, right, center or justify        |
| `textStyle.lineHeight`         | The text style's line height, if exists                                             |
| `textStyle.letterSpacing`      | The text style's letter spacing, if exists                                          |
| `textStyle.identity`           | The identity/name of the text style as defined on Zeplin                            |
| `textStyle.identity.camelcase` | The identity/name of the text style, formatted in camel case (e.g. `myTextStyle`)   |
| `textStyle.identity.snakecase` | The identity/name of the text style, formatted in snake case (e.g. `my_text_style`) |
| `textStyle.color.*`            | All color tokens from the section above can be used for a TextStyle's color         |

## Spacing Tokens

| Token                        | Description                                                                       |
|------------------------------|-----------------------------------------------------------------------------------|
| `spacing.value`              | The value of the current spacing token                                            |
| `spacing.identity`           | The identity/name of the spacing token, as defined on Zeplin                      |
| `spacing.identity.camelcase` | The identity/name of the spacing token, formatted in camel case                   |
| `spacing.identity.snakecase` | The identity/name of the spacing token, formatted in snake case                   |