% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/StatMPWR.R
\docType{class}
\name{StatMPWR-class}
\alias{StatMPWR-class}
\alias{StatMPWR}
\title{A Reference Class which contains statistics of a MPWR model.}
\description{
StatMPWR contains all the statistics associated to a \link[=ParamMPWR]{MPWR} model.
}
\section{Fields}{

\describe{
\item{\code{z_ik}}{Logical matrix of dimension \eqn{(m, K)} giving the class vector.}

\item{\code{klas}}{Column matrix of the labels issued from \code{z_ik}. Its elements are
\eqn{klas(i) = k}, \eqn{k = 1,\dots,K}.}

\item{\code{mean_function}}{Approximation of the time series given the estimated
parameters. \code{mean_function} is a matrix of size \eqn{(m, d)}.}

\item{\code{regressors}}{Array of size \eqn{(m, d, K)} giving the values of the
estimated polynomial regression components.}

\item{\code{objective}}{Numeric. Value of the objective function.}
}}

\section{Methods}{

\describe{
\item{\code{computeStats(paramMPWR)}}{Method used at the end of the dynamic programming algorithm to compute
statistics based on parameters provided by \code{paramMPWR}.}
}}

\seealso{
\link{ParamMPWR}
}
