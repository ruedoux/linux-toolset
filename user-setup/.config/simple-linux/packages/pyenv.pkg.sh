pkgname=pyenv
pkgver=2.7.2
pkgrel=1
depends=('make' 'gcc')
url="https://github.com/pyenv/pyenv"
source=("pyenv-${pkgver}.zip::${url}/archive/refs/tags/v${pkgver}.zip")
sha256sums=('46f8e9270f582041571aeefd924bd05ef9def6481d2dc090c15ca025c6ddb09c')

build() {
  cd "${srcdir}/pyenv-${pkgver}"
  src/configure
  make -C src
}

package() {
  install -d "${pkgdir}/.pyenv"
  cp -r "${srcdir}/pyenv-${pkgver}/." "${pkgdir}/.pyenv/"
}