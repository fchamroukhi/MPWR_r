#' A Reference Class which contains the parameters of a MPWR model.
#'
#' ParamMPWR contains all the parameters of a MPWR model. The parameters are
#' calculated by the initialization Method and then updated by the Method
#' dynamic programming (here dynamic programming)
#'
#' @field X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @field Y Numeric vector of length \emph{m} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{m}}.
#' @field m Numeric. Length of the response/output vector `Y`.
#' @field K The number of regimes (PWR components).
#' @field p The order of the polynomial regression. `p` is fixed to 3 by
#'   default.
#' @field gamma Set of transition points. `gamma` is a column matrix of size
#'   \eqn{(K + 1, 1)}.
#' @field beta Parameters of the polynomial regressions. `beta` is an array of
#'   dimension \eqn{(p + 1, d, K)}, with `p` the order of the polynomial
#'   regression, `d` the dimension of the multivariate time-series. `p` is fixed
#'   to 3 by default.
#' @field sigma2 The variances for the `K` regimes. `sigma2` is an array of size
#'   \eqn{(d, d, K)}.
#' @field phi A matrix giving the regression design matrix for the polynomial
#'   regression.
#' @export
ParamMPWR <- setRefClass(
  "ParamMPWR",
  fields = list(
    mData = "MData",
    phi = "matrix",

    K = "numeric", # Number of regimes
    p = "numeric", # Dimension of beta (order of polynomial regression)

    gamma = "matrix",
    beta = "array",
    sigma2 = "array"
  ),
  methods = list(
    initialize = function(mData = MData(numeric(1), matrix(1)), K = 1, p = 3) {
      mData <<- mData

      phi <<- designmatrix(x = mData$X, p = p)$XBeta

      K <<- K
      p <<- p

      gamma <<- matrix(NA, K + 1)
      beta <<- array(NA, dim = c(p + 1, mData$d, K))
      sigma2 <<- array(NA, dim = c(mData$d, mData$d, K))

    },

    computeDynamicProgram = function(C1, K) {
      "Method which implements the dynamic programming based on the cost matrix
      \\code{C1} and the number of regimes/segments \\code{K}."

      # Dynamic programming
      solution <- dynamicProg(C1, K)
      Ck <- solution$J
      gamma <<- matrix(c(0, solution$t_est[nrow(solution$t_est),]))  # Change points
      return(Ck)
    },

    computeParam = function() {
      "Method which estimates the parameters \\code{beta} and \\code{sigma2}
      knowing the transition points \\code{gamma}."

      for (k in 1:K) {
        i <- gamma[k] + 1
        j <- gamma[k + 1]
        nk <- j - i + 1
        Yij <- mData$Y[i:j, ]
        X_ij <- phi[i:j, , drop = FALSE]
        beta[, , k] <<- solve(t(X_ij) %*% X_ij, tol = 0) %*% t(X_ij) %*% Yij

        z <- Yij - X_ij %*% beta[, , k]
        sigma2[, , k] <<- t(z) %*% z / nk # Variances
      }
    }
  )
)
