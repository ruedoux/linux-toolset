pkgname=shellcheck
pkgver=0.11.0
pkgrel=1
url="https://github.com/koalaman/shellcheck"
source=("shellcheck-v${pkgver}.linux.x86_64.tar.gz::${url}/releases/download/v${pkgver}/shellcheck-v${pkgver}.linux.x86_64.tar.gz")
sha256sums=('b7af85e41cc99489dcc21d66c6d5f3685138f06d34651e6d34b42ec6d54fe6f6')

package() {
  install -D "${srcdir}/shellcheck-v${pkgver}/shellcheck" "${pkgdir}/.local/bin/shellcheck"
}
