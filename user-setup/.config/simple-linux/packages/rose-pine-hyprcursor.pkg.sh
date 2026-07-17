pkgname=rose-pine-hyprcursor
pkgver=0.3.2
pkgrel=1
url="https://github.com/ndom91/rose-pine-hyprcursor"
source=("rose-pine-cursor-hyprcursor_${pkgver}.tar.gz::${url}/releases/download/v${pkgver}/rose-pine-cursor-hyprcursor_${pkgver}.tar.gz")
sha256sums=('5e84afe47ef723c465317bc58710f4e45b0b36366d4d88bf0325c712b711b58e')

package() {
  install -d "${pkgdir}/.local/share/icons/rose-pine-hyprcursor"
  cp -r "${srcdir}/hyprcursors" "${srcdir}/manifest.hl" "${pkgdir}/.local/share/icons/rose-pine-hyprcursor"
}