# Vim-NPR :mag_right:
A plugin for sensible Node Path Relative module resolution in Javascript on a project-by-project basis.

## Usage
Works with ES, AMD, and CommonJS module definitions.

An example of the possible module resolution types are below, provided correct configuration. {NPR} represents a configured or default relative directory, which can be specified in your package.json as the resolve array:

```javascript
import Header from 'Header';            // will resolve {NPR}/Header/index.js
import Header from 'Header/index.js';   // will resolve {NPR}/Header/index.js
import Header from 'Header/style.css';  // will resolve {NPR}/Header/style.css
import Button from 'Header/Button';     // will resolve {NPR}/Header/Button/index.js

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
