% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wishart.R
\name{estimate_wishart}
\alias{estimate_wishart}
\alias{estimate_wishart_mean}
\title{Estimate parameters of a isotropic Wishart distribution}
\usage{
estimate_wishart(res, dof, ...)

estimate_wishart_mean(res, dof, mean, ...)
}
\arguments{
\item{res}{list of 2x2 matrices}

\item{dof}{initial guess for degrees of freedom}

\item{...}{other parameters passed to optim

For Y with Wishart distribution with dof degrees of freedom and gam*I covariance function
Estimates dof and gam from sample.}
}
\description{
Estimate parameters of a isotropic Wishart distribution

Estimate parameters of a isotropic Wishart distribution with shift
}
