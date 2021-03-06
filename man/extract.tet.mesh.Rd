% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract.R
\name{extract.tet.mesh}
\alias{extract.tet.mesh}
\title{Extracts points and triangles from fracture_geom}
\usage{
extract.tet.mesh(
  obj,
  type = c("top", "bottom"),
  transform = function(points) points,
  genie.h
)
}
\arguments{
\item{obj}{the fracture_geom object}

\item{type}{selects one or more of: top, bottom, middle, border, edge}

\item{genie.h}{level for snapping points together (needs genieclust package)}

\item{tranform}{the function used for transform the points}
}
\description{
Extracts points and triangles from fracture_geom
}
