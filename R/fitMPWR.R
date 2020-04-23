#' fitMPWR implements an optimized dynamic programming algorithm to fit a
#' MPWR model.
#'
#' fitMPWR is used to fit a Mulitvariate Piecewise Regression (MPWR) model
#' by maximum-likelihood via an optimized dynamic programming algorithm. The
#' estimation performed by the dynamic programming algorithm provides an optimal
#' segmentation of the time series.
#'
#' @details fitMPWR function implements an optimized dynamic programming
#'   algorithm of the MPWR model. This function starts with the calculation of
#'   the "cost matrix" then it estimates the transition points given `K` the
#'   number of regimes thanks to the method `computeDynamicProgram` (method of
#'   the class [ParamMPWR][ParamMPWR]).
#'
#' @param X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @param Y Matrix of size \eqn{(m, d)} representing a \eqn{d} dimension
#'   function of `X` observed at points \eqn{1,\dots,m}. `Y` is the observed
#'   response/output.
#' @param K The number of regimes/segments (PWR components).
#' @param p Optional. The order of the polynomial regression. By default, `p` is
#'   set at 3.
#' @return fitMPWR returns an object of class [ModelMPWR][ModelMPWR].
#' @seealso [ModelMPWR], [ParamMPWR], [StatMPWR]
#' @export
#'
#' @examples
#' data(toydataset)
#' x <- toydataset$x
#' Y <- as.matrix(toydataset[,c("y1", "y2", "y3")])
#'
#' mpwr <- fitMPWR(X = x, Y = Y, K = 5, p = 1)
#'
#' mpwr$summary()
#'
#' mpwr$plot()
fitMPWR = function(X, Y, K, p = 3) {

  if (is.vector(Y) || is.data.frame(Y)) { # Univariate time series or data frame
    Y <- as.matrix(Y)
  }
  mData <- MData(X, Y)

  Lmin <- p + mData$d # 1

  param <- ParamMPWR(mData = mData, K = K, p = p)

  C1 <- costMatrix(Y, param$phi, Lmin)

  Ck <- param$computeDynamicProgram(C1, K)

  param$computeParam()

  stat <- StatMPWR(param = param)

  # Compute statistics
  stat$computeStats(param)

  stat$objective = Ck[length(Ck)]

  return(ModelMPWR(param = param, stat = stat))
}
