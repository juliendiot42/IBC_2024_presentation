# IBC 2024 Presentation, *R-shiny for Interactive Data Visualisation, Example of PlantBreedGame: A serious game to teach Genomic selection*

This repository contains the source code of Julien DIOT's the presentation during the 
[IBC 2024](https://www.ibc2024.org/home)'s invited session *"Interactive Visualisation for Effective Decision-making in Agricultural and Environmental Sciences"*


## Starting the presentation

### With `nix`

If you have [nix](https://nixos.org/) installed, you can simply run: 

```sh
nix run github:juliendiot42/IBC_2024_presentation\#presentation
```

You can then access the presentation by opening your web browser and go to http://localhost:3838 .

### With `docker`

If you have [docker](https://www.docker.com/) installed, you can simply run: 

```sh
docker run -p 3838:3838 ghcr.io/juliendiot42/ibc_2024_presentation/ibc2024presentation:latest
```

You can then access the presentation by opening your web browser and go to http://localhost:3838 .

### With R (discouraged)

I recommend to rather using the "nix" or "docker" method presented above because
they are fully reproducible and all the dependencies will be automatically manages
(except for nix or docker).

For those who want to run the presentation from their own R environement, you
can find the list of the R-packages required to run the presentation in the file
`flake.nix` after the line:

```nix
R-packages = with Rpkgs.rPackages; [
```

(approximatly [here](https://github.com/juliendiot42/IBC_2024_presentation/blob/master/flake.nix#L38))

> Notes:  
> The R vesion used in this repo is `4.3.3 (2024-02-29) -- "Angel Food Cake"`  
> The Pandoc version used in this repo is:
>  ```
>  pandoc 3.1.11.1
>  Features: +server +lua
>  Scripting engine: Lua 5.4
>  ```

