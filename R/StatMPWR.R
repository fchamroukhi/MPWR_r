#' A Reference Class which contains statistics of a PWR model.
#'
#' StatMPWR contains all the statistics associated to a [MPWR][ParamMPWR] model.
#'
#' @field z_ik Logical matrix of dimension \eqn{(m, K)} giving the class vector.
#' @field klas Column matrix of the labels issued from `z_ik`. Its elements are
#'   \eqn{klas(i) = k}, \eqn{k = 1,\dots,K}.
#' @field mean_function Approximation of the time series given the estimated
#'   parameters. `mean_function` is a matrix of size \eqn{(m, d)}.
#' @field regressors Array of size \eqn{(m, d, K)} giving the values of the
#'   estimated polynomial regression components.
#' @field objective Numeric. Value of the objective function.
#' @seealso [ParamMPWR]
#' @export
StatMPWR <- setRefClass(
  "StatMPWR",
  fields = list(
    z_ik = "matrix",
    klas = "matrix",
    mean_function = "matrix",
    regressors = "array",
    objective = "numeric"
  ),
  methods = list(
    initialize = function(paramMPWR = ParamMPWR()) {
      z_ik <<- matrix(0, paramMPWR$mData$m, paramMPWR$K)
      klas <<- matrix(NA, paramMPWR$mData$m, 1)
      mean_function <<- matrix(NA, nrow = paramMPWR$mData$m , ncol = paramMPWR$mData$d)
      regressors <<- array(NA, dim = c(paramMPWR$mData$m, paramMPWR$mData$d, paramMPWR$K))
      objective <<- -Inf

    },

    computeStats = function(paramMPWR) {
      "Method used at the end of the dynamic programming algorithm to compute
      statistics based on parameters provided by \\code{paramMPWR}."

      # Estimated classes and mean function
      for (k in 1:paramMPWR$K)  {

        i <- paramMPWR$gamma[k] + 1
        j <- paramMPWR$gamma[k + 1]

        klas[i:j] <<- k
        z_ik[i:j, k] <<- 1

        beta <- paramMPWR$beta[, , k]
        dim(beta) <- c(paramMPWR$p + 1, paramMPWR$mData$d)

        # Regressors
        regressors[, , k] <<- paramMPWR$phi %*% beta

        X_ij <- paramMPWR$phi[i:j, ]
        mean_function[i:j, ] <<- X_ij %*% beta
      }
    }
  )
)
