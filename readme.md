# Dukascopy Connect Mobile


### Using with VSCODE
1. install vscode from https://code.visualstudio.com/
2. install plugin for vscode ActionScript & MXML
3. create asconfig.json file into to project folder
4. setup AIR SDK (ctrl+p -> Action Script Select Workspace SDK)
5. To build project once: Terminal -> Run build task -> Action Script - compile debug asconfig.json
6. To create build & run task: press F5, select SWF, be sure to create tasks as shown below
7. config documentation: https://as3mxml.com/



### EXAMPLE OF asconfig.json
```json
{
    "config": "airmobile",
    "compilerOptions": {
        "default-frame-rate": 60,
        "use-gpu": true,
        "advanced-telemetry": true,
        "source-path": [
            "src"
        ],
        "load-config": [
            "conf/project.xml"
        ],
        "debug": true,
        "output": "./bin/Dukascopy.swf"
    },

    "airOptions": {
		"extdir": [
			"lib/ane"
		]
	},

    "mainClass": "Main",
    "application":"conf/desktop.xml"
}
```

### EXAMPLE OF .vscode/launch.json
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "swf",
            "request": "launch",
            "name": "Build & Launch SWF",
            "profile": "mobileDevice",
            "screensize": "iPhoneRetina",
            "screenDPI": 326,
            "versionPlatform": "IOS",
            "extdir": "lib/debug",
            "preLaunchTask": "ActionScript: compile debug - asconfig.json"
        },
        {
            "type": "swf",
            "request": "launch",
            "name": "Launch SWF",
            "profile": "mobileDevice",
            "screensize": "iPhoneRetina",
            "screenDPI": 326,
            "versionPlatform": "IOS",
            "extdir": "lib/debug",
        }
    ]
}
```