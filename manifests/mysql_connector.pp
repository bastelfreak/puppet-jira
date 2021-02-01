# Class to install the MySQL Java connector
class jira::mysql_connector (
  $version      = $jira::mysql_connector_version,
  $product      = $jira::mysql_connector_product,
  $format       = $jira::mysql_connector_format,
  $installdir   = $jira::mysql_connector_install,
  $download_url = $jira::mysql_connector_url
) {
  require staging

  $file = "${product}-${version}.${format}"

  if ! defined(File[$installdir]) {
    file { $installdir:
      ensure => 'directory',
      owner  => root,
      group  => root,
      before => Staging::File[$file],
    }
  }

  if (versioncmp($jira::mysql_connector_version, '8.0.0') == -1) { # version < 8.0.0
    $jarfile = "${product}-${version}-bin.jar"
  } else {
    $jarfile = "${product}-${version}.jar"
  }

  staging::file { $file:
    source  => "${download_url}/${file}",
    timeout => 300,
  }

  -> staging::extract { $file:
    target  => $installdir,
    creates => "${installdir}/${product}-${version}",
  }

  -> file { "${jira::webappdir}/lib/mysql-connector-java.jar":
    ensure => link,
    target => "${installdir}/${product}-${version}/${jarfile}",
  }
}
