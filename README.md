# Vim-NPR :mag_right::bookmark_tabs:
A plugin for sensible Node Path Relative module resolution in Javascript on a project-by-project basis. This will allow Vim to resolve modules using `gf`, even when they're using Node Path Relative, or custom resolution directories in your webpack configuration.

## Installation
Supports Vim-Plug, Vundle, and likely any other vim plugin manager that uses a similar format.

Add the following line to your `.vimrc` file:
```vim
Plug 'tomarrell/vim-npr'
```

## Configuration
Simply add a resolve key to your project's `package.json` file with an array of directories you would like the file to potentially be resolved relative to. The plugin will find this key and resolve your files as per the directories listed. 

If a `package.json` file can be found, however no `resolve` key is present, the plugin will default to the following directories for resolution:
```js
{
  // ...
  "resolve": ["src", "lib", "test", "public", "node_modules"],
  // ...
}
```
If these directories don't exist, or the plugin cannot find the file under the cursor, the plugin will simply fail to resolve the file.

By default, the plugin will resolve the `package.json` by traversing up *5* directories, this number is configurable using the `g:vim_npr_max_levels` variable.

The plugin will be active whenever you enter a buffer with the extension .js, .jsx, .css or .coffee.

Finally, if the exact file name with extension is not provided in the path, the plugin will attempt a list of defaults. These are appended to the path for each match attempt. The default list is:

```vim
let g:vim_npr_file_names = ["", ".js", "/index.js"]
```

Note that "" (empty string) and ".js" (plain .js extension) are important to resolve exact files and paths simply omitting the extension respectively. 

## Usage
Works with ES, AMD, and CommonJS module definitions.

An example of the possible module resolution types are below, provided correct configuration. {NPR} represents a configured or default relative directory, which can be specified in your package.json as the resolve array:

```javascript
import Header from 'Header';            // will resolve {NPR}/Header/index.js
import Header from 'Header/index.js';   // will resolve {NPR}/Header/index.js
import Header from 'Header/style.css';  // will resolve {NPR}/Header/style.css
import Button from 'Header/Button';     // will resolve {NPR}/Header/Button/index.js

import Header from '~/components/Header';          // will resolve {NPR}/components/Header/index.js
import Header from '~/components/Header/index.js'; // will resolve {NPR}/components/Header/index.js

import React from 'react';              // will resolve {NPR}/react/index.js
import { connect } from 'react-redux';  // will resolve {NPR}/react-redux/lib/
```

It even works throughout your CSS.
```css
@import 'variables.css';  /* will resolve {NPR}/variables.css */
@import 'Home/style.css'; /* will resolve {NPR}/Home/style.css */
```

It functions the same as the traditional vim *gf* command, without getting in the way of your other language file resolvers.

## License
Licensed under the GNU GPL v3.0 license. Please see the extended license terms [here](https://www.gnu.org/licenses/gpl-3.0).
