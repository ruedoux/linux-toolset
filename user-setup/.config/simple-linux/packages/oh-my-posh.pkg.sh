pkgname=oh-my-posh-bin
pkgver=29.18.0
pkgrel=1
url="https://github.com/JanDeDobbeleer/oh-my-posh"
source=("posh-linux-amd64::${url}/releases/download/v${pkgver}/posh-linux-amd64")
sha256sums=('79b4026af3618424f3b946bdc00e84cdec007f318ca30d13271c56ff420a6551')

package() {
  install -D "${srcdir}/posh-linux-amd64" "${pkgdir}/.local/bin/oh-my-posh"
}