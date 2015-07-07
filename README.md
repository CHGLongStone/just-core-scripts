# just-core-scripts
just core management scripts

##Purpose
Basic management scripts to deploy release etc based on the [just-core-stub](https://github.com/CHGLongStone/just-core-stub) project

##Project Layout
The project deals primarily with the production environment but references the development environment in instances

It is expected that your project will follow a fairly standard SDLC with fixed releases based on tags
with a layout like

```
#ls -alh /var/www/vhosts
	[project_name] -> [project_name]_release/current
	[project_name]_release
		cfg
		current -> v0.0.3
		v0.0.1
		v0.0.2
		v0.0.3
			...
			AUTOLOAD -> ../../cfg
			...
	[domain1].com
		http -> ../[project_name]/APIS/[API_NAME_1]/
	[dev*].[domain1].com
		http -> ../[project_name]_dev/APIS/[API_NAME_1]/
	[domain2].com
		http -> ../[project_name]/APIS/[API_NAME_2]/
	[dev*].[domain2].com
		http -> ../[project_name]_dev/APIS/[API_NAME_2]/
	[project_name]_dev


```

the production release script will follow the routine of
* checking out the release tag into directory `[project_name]_release/[release_tag]`
* updates composer in the new checkout
* setting a maintenance notice in the existing `[project_name]/` directory 
* copying any files in `CONFIG/AUTOLOAD/` with the mask of `*.global.php` into `[project_name]_release/cfg/`
	* consuming upstream changes
	* preserving local changes (with the mask of `*.local.php` )
* creating the symlink `AUTOLOAD -> ../../cfg`
* doing any database operations
* deleting and recreating the symlink `[project_name]_release/current` to the updated release version
* maintenance notice is automatically taken down








