% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotting.R
\name{write.stl.fracture_geom}
\alias{write.stl.fracture_geom}
\title{Writes a mesh3d object (or a list) to an stl file}
\usage{
\method{write.stl}{fracture_geom}(x, con, ascii = FALSE, type = c("top", "bottom"), ...)
}
\arguments{
\item{x}{list of meshes to write}

\item{con}{file connection of filename to write to}

\item{ascii}{if TRUE, write in ASCII format (discouraged)}
}
\description{
Writes a mesh3d object (or a list) to an stl file
}
