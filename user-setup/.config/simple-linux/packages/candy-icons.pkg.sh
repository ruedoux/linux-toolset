pkgname=candy-icons
pkgver=master
pkgrel=1
depends=('gtk-update-icon-cache')
url="https://github.com/EliverLara/candy-icons"
source=("${pkgname}-${pkgver}.zip::${url}/archive/refs/heads/master.zip")
sha256sums=('2ac60f85e5d61555b9b733b5a02dcc050329c2ab572b304e87512d6268652fdb')

package() {
  install -d "${pkgdir}/.local/share/icons/candy-icons"
  cp -r "${srcdir}/candy-icons-master/." "${pkgdir}/.local/share/icons/candy-icons/"
}