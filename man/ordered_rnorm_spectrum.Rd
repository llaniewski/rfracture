% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fracture_matrix.R
\name{ordered_rnorm_spectrum}
\alias{ordered_rnorm_spectrum}
\title{Generate a matrix of random complex numbers in a consistent order}
\usage{
ordered_rnorm_spectrum(f, k = 2, seed, length_one = FALSE)
}
\arguments{
\item{f}{table of frequencies (wave numbers)}

\item{k}{number of independent matrices}

\item{seed}{random seed}

\item{length_one}{if TRUE, return complex numbers of length 1}
}
\description{
Generate a matrix of random complex numbers in a consistent order
}
\examples{
f = expand.grid(0:1,0:1)
ordered_rnorm_spectrum(f, seed=123)
}
