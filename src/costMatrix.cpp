// [[Rcpp::depends(RcppArmadillo)]]

#include <RcppArmadillo.h>

using namespace Rcpp;

// [[Rcpp::export]]
arma::mat costMatrix(arma::mat& y, arma::mat& X, double Lmin = 1) {

    double n = y.n_rows;
    double d = y.n_cols;

    double nl = n - Lmin + 1;
    double nk;

    arma::Mat<double> sigma2 = arma::mat(d, d, arma::fill::eye);
    arma::colvec mahalanobis(d, arma::fill::zeros);

    arma::Mat<double> C1 = arma::mat(n, n);
    C1.fill(arma::datum::inf);
    C1 = arma::trimatl(C1, Lmin - 2);

    for (int a = 0; a <= nl; a++) {

      if ((a + Lmin) <= n) { // To check

        // ############################################################################
        // # Condition added to handle the cases (a + 1 + Lmin) > n                   #
        // ############################################################################

        for (int b = (a + Lmin); b < n; b++)  {

          arma::mat yab = y.rows(a, b);
          arma::mat X_ab = X.rows(a, b);

          nk = b - a;

          arma::mat beta = pinv(X_ab.t() * X_ab) * X_ab.t() * yab;
          arma::mat z = yab - X_ab * beta;
          sigma2 = z.t() * z / nk;
          mahalanobis = arma::sum((z * pinv(sigma2)) % z, 1);

          C1(a, b) = nk * (d / 2) * std::log(2 * arma::datum::pi) + nk * 0.5 * std::log(arma::det(sigma2)) + 0.5 * arma::sum(mahalanobis);
        }
      }
    }

    return C1;
}
