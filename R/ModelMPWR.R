#' A Reference Class which represents a fitted MPWR model.
#'
#' ModelMPWR represents an estimated MPWR model.
#'
#' @field param A [ParamMPWR][ParamMPWR] object. It contains the estimated values
#'   of the parameters.
#' @field stat A [StatMPWR][StatMPWR] object. It contains all the statistics
#'   associated to the MPWR model.
#' @seealso [ParamMPWR], [StatMPWR]
#' @export
#'
#' @examples
#' data(toydataset)
#' x <- toydataset$x
#' Y <- as.matrix(toydataset[,c("y1", "y2", "y3")])
#'
#' mpwr <- fitMPWRFisher(X = x, Y = Y, K = 5, p = 1)
#'
#' # mpwr is a ModelMPWR object. It contains some methods such as 'summary' and 'plot'
#' mpwr$summary()
#' mpwr$plot()
#'
#' # mpwr has also two fields, stat and param which are reference classes as well
#'
#' # Value of the objective function:
#' mpwr$stat$objective
#'
#' # Parameters of the polynomial regressions:
#' mpwr$param$beta
ModelMPWR <- setRefClass(
  "ModelMPWR",
  fields = list(
    param = "ParamMPWR",
    stat = "StatMPWR"
  ),
  methods = list(

    plot = function(what = c("regressors", "segmentation"), ...) {
      "Plot method.
      \\describe{
        \\item{\\code{what}}{The type of graph requested:
          \\itemize{
            \\item \\code{\"regressors\" = } Polynomial regression components
              (field \\code{regressors} of class \\link{StatMPWR}).
            \\item \\code{\"segmentation\" = } Estimated signal
              (field \\code{mean_function} of class \\link{StatMPWR}).
          }
        }
        \\item{\\code{\\dots}}{Other graphics parameters.}
      }
      By default, all the graphs mentioned above are produced."

      what <- match.arg(what, several.ok = TRUE)

      oldpar <- par(no.readonly = TRUE)
      on.exit(par(oldpar), add = TRUE)

      yaxislim <- c(min(param$mData$Y) - 2 * mean(sqrt(apply(param$mData$Y, 2, var))), max(param$mData$Y) + 2 * mean(sqrt(apply(param$mData$Y, 2, var))))

      colorsvec <- rainbow(param$K)

      if (any(what == "regressors")) {
        # Time series, regressors, and segmentation
        par(mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        matplot(param$mData$X, param$mData$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", col = gray.colors(param$mData$d), lty = 1, ...)
        title(main = "Time series, MPWR regimes, and segmentation")
        for (k in 1:param$K) {
          index <- stat$klas == k

          for (d in 1:param$mData$d) {
            regressors <- stat$regressors[index, d, k]
            lines(param$mData$X, stat$regressors[, d, k], col = colorsvec[k], lty = "dotted", lwd = 1, ...)
            lines(param$mData$X[index], regressors, col = colorsvec[k], lwd = 1.5, ...)
          }
        }
      }

      if (any(what == "segmentation")) {
        # Time series, estimated regression function, and optimal segmentation
        matplot(param$mData$X, param$mData$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", col = gray.colors(param$mData$d), lty = 1, ...)
        title(main = "Time series, MPWR function, and segmentation")

        for (k in 1:param$K) {
          Ik = param$gamma[k] + 1:(param$gamma[k + 1] - param$gamma[k])
          for (d in 1:param$mData$d) {
            segmentk = stat$mean_function[Ik, d]
            lines(param$mData$X[t(Ik)], segmentk, type = "l", col = colorsvec[k], lwd = 1.5, ...)
          }
        }

        for (i in 1:length(param$gamma)) {
          abline(v = param$mData$X[param$gamma[i]], col = "red", lty = "dotted", lwd = 1.5, ...)
        }
      }
    },

    summary = function(digits = getOption("digits")) {
      "Summary method.
      \\describe{
        \\item{\\code{digits}}{The number of significant digits to use when
          printing.}
      }"

      title <- paste("Fitted MPWR model")
      txt <- paste(rep("-", min(nchar(title) + 4, getOption("width"))), collapse = "")

      # Title
      cat(txt)
      cat("\n")
      cat(title)
      cat("\n")
      cat(txt)

      cat("\n")
      cat("\n")
      cat(paste0("MPWR model with K = ", param$K, ifelse(param$K > 1, " components", " component"), ":"))
      cat("\n")

      cat("\nClustering table (Number of observations in each regimes):\n")
      print(table(stat$klas))

      cat("\n\n")

      txt <- paste(rep("-", min(nchar(title), getOption("width"))), collapse = "")

      for (k in 1:param$K) {
        cat(txt)
        cat("\nRegime ", k, " (k = ", k, "):\n", sep = "")

        cat("\nRegression coefficients:\n\n")
        if (param$p > 0) {
          row.names = c("1", sapply(1:param$p, function(x) paste0("X^", x)))
        } else {
          row.names = "1"
        }

        betas <- data.frame(param$beta[, , k, drop = FALSE], row.names = row.names)
        colnames(betas) <- sapply(1:param$mData$d, function(x) paste0("Beta(d = ", x, ")"))
        print(betas, digits = digits)

        cat("\nCovariance matrix:\n")
        sigma2 <- data.frame(param$sigma2[, , k])
        colnames(sigma2) <- NULL
        print(sigma2, digits = digits, row.names = FALSE)
      }

    }
  )
)
