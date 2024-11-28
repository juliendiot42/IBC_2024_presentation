# IBC 2024 Presentation, *Interactive Data Visualization in R with Shiny, Example of PlantBreedGame, A serious game to Teach Genomic Selection.*

This repository contains the source code of Julien DIOT's the presentation during the 
[IBC 2024](https://www.ibc2024.org/home)'s invited session *"Interactive Visualisation for Effective Decision-making in Agricultural and Environmental Sciences"*

> Abstract:
>
> Shiny is an R package that enables the creation of interactive web
> applications directly from the R language. Combining R's analytical, data
> processing and data visualisation power, Shiny allows statisticians and data
> analysts familiar with R to develop web applications that bring interactivity
> to their projects without requiring extensive web development experience.
> 
> This presentation will begin with an introduction to Shiny through simple
> applications, illustrating how Shiny applications are structured. We’ll explore
> the two main components of a Shiny app: the "UI" (ie. User Interface) part that
> defines the visual interface of the application the users see and interact with,
> and the "server" part that specifies the logic that processes the inputs from
> the UI and generates the corresponding outputs to display. This foundational
> overview will demonstrate how easy it is to build applications with Shiny.
> 
> Following this introduction, I will present a more advanced example,
> PlantBreedGame, an open-source web application designed as a serious game to
> teach students and professionals the principles of selective breeding. In
> PlantBreedGame, players take the role of a plant breeder and must carry out a
> successful selection campaign from an initial plant collection identical for all
> the participants. The game provides interfaces to let the players carry out
> phenotyping, genotyping and various types of cross-breeding. In the background,
> the application simulates data based on these actions using algorithms that
> mimic genetic variation and inheritance patterns. Players can then download
> those data from the game for further analysis regarding their breeding
> strategies. At the end of the game, players submit some selected individuals
> from their breeding efforts to be compared against those of other players.
> The application then generates comparative visualizations to evaluate the
> performance of each player’s selections, providing an engaging and competitive
> aspect to the learning experience. Moreover, this visual feedback encourages
> participants to reflect on their breeding approaches.
> 
> Finally, I will discuss some limitations and considerations in developing
> Shiny applications, including performance and scalability challenges, and
> customization options. However, these caveats are balanced by Shiny’s
> accessibility and ease of use, making it an effective tool for R developers
> without extensive web development experience.

## Some References

#### `Shiny`
- `Shiny`'s official website: https://shiny.posit.co/
- Source code (for `R`): https://github.com/rstudio/shiny
- `Shiny`'s gallery (several app examples): https://shiny.posit.co/r/gallery/
- List of basic UI inputs: https://gallery.shinyapps.io/081-widgets-gallery/
- (`R`) `Shiny` extentions: https://github.com/nanxstats/awesome-shiny-extensions


#### `PlantBreedGame`
- *PlantBreedGame* repository: https://github.com/timflutre/PlantBreedGame

## Repository structure

Feel free to use those codes for your own projects!

#### Presentation:
- [`IBC_2024.Rmd`](./IBC_2024.Rmd): The (interactive) presentation source code  
- [`./src/`](./src/): Ressources for the presentation (eg. images, CSS)

#### Presented shiny example (from R-Studio):
- [`./shiny_app_examples/`](./shiny_app_example/): example of R-Shiny apps

#### Nix stuff:

The presentation is actually a web application which can be sometime difficult to reproduce (the famouse "it works on my machine" problem) nix handle that very well.

- [`./flake.nix`](./flake.nix): Specifies the (highly reproducible) development environment.
This is were all packages required for running the presentation are defined (this goes from the R packages, R its self, PlantBreedGame and and other system package like pandoc, and all their respective dependencies)
- [`./flake.lock`](./flake.lock): Pins the versions of those packages
- [`./dockerfile.nix`](./dockerfile.nix): To build the docker image that contain the presentation from Nix
- [`./default.nix`](./default.nix): To package the presentation as its "own software".


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

