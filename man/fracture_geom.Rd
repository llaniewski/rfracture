% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fracture_geom.R
\name{fracture_geom}
\alias{fracture_geom}
\title{Generate a 3D fracture geometry with trianglar mesh}
\usage{
fracture_geom(width = 1, refine = 1, method = c("triangles", "diagonals"), ...)
}
\arguments{
\item{width}{linear dimension of the square cut of the fracture}

\item{refine}{refinement level}

\item{...}{parameters passed to fracture_matrix function}

\item{power.spectrum}{power spectrum of the fields (function of frequency)}

\item{corr.profile}{correlation profile between (function of wave length)}
}
\description{
Generate a 3D fracture geometry with trianglar mesh
}
\examples{
ret = fracture_geom(
  width = 1,
  refine = 10,
  corr.profile = function(lambda) 0.5,
  closed=0.1,
  power.iso = exp_spectrum(scale=0.01, alpha=3)
)
if (require(rgl)) fracture3d(cut(ret))

}
