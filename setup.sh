#!/bin/sh
# set -ex


print () {
  color="$1"
  shift
  printf "\033[1;3%sm%s\033[00m\n" "$color" "$*"
}

copy_with_backup () {
  src=$1
  dest=$2
  mode=$3

  if [ -e "$dest" ]; then
    print 1 "==> '$dest' exists; creating a backup at ${dest}.bk..."
    mv "${dest}" "${dest}.bk"
  fi
  print 3 "==> Installing $src to $dest ($mode)"
  cp -r "$src" "$dest"

  chmod -R "$mode" "$dest"
}

grab_dep () {
  if [ ! -d deps/$1 ]; then
    mkdir -p deps/$1
    pushd deps > /dev/null
      git clone http://git.suckless.org/$2 --depth 1
    popd > /dev/null
  else
    pushd deps/$1 > /dev/null
      git pull --ff-only
    popd > /dev/null
  fi
}

which git > /dev/null || (echo "Please install git" && exit 1)

# make all our dest directories
[ ! -d "$ROOT" ] && mkdir -p "$ROOT"
[ ! -d "$ROOT"/etc/ ] && mkdir -p "$ROOT"/etc/
[ ! -d "$ROOT"/bin ] && mkdir "$ROOT"/bin/
[ ! -d "$ROOT"/usr/bin ] && mkdir "$ROOT"/usr/bin/
[ ! -d "$ROOT"/usr/share/zsh/site-functions/ ] && mkdir -p "$ROOT"/usr/share/zsh/site-functions/

# pull all our dependencies
grab_dep ubase http://git.suckless.org/ubase
grab_dep sinit http://git.suckless.org/sinit

# install all of our dependencies
pushd deps > /dev/null
  if [ ! -f /usr/bin/getty ]; then
    # ubase
    pushd ubase > /dev/null
      print 3 "==> Installing ubase"
      make ubase-box
      cp ubase-box "$ROOT"/usr/bin
      ln -s "$ROOT"/usr/bin/ubase-box "$ROOT"/usr/bin/getty
      ln -s "$ROOT"/usr/bin/ubase-box "$ROOT"/usr/bin/respawn
      ln -s "$ROOT"/usr/bin/ubase-box "$ROOT"/usr/bin/halt
      ln -s "$ROOT"/usr/bin/ubase-box "$ROOT"/usr/bin/killall5
    popd > /dev/null
  else
    print 2 "==> ubase seems to be installed. Skipping..."
  fi

  if [ ! -f "$ROOT"/bin/sinit ]; then
    # sinit
    pushd sinit > /dev/null
      print 3 "==> Installing sinit"
      cp ../../sinit_config config.h
      make
      cp sinit "$ROOT"/bin/sinit
    popd > /dev/null
  else
    print 2 "==> sinit seems to be installed. Skipping..."
  fi

popd > /dev/null

# copy stuff to the dest
copy_with_backup rc.d "$ROOT"/etc/rc.d 755
copy_with_backup rc "$ROOT"/bin/rc 755
copy_with_backup rc.conf "$ROOT"/etc/rc.conf 644

# install extras
print 3 "==> Installing extras"
pushd extra > /dev/null
  copy_with_backup _rc "$ROOT"/usr/share/zsh/site-functions/_rc 644
  # install -Dm755 shutdown.sh "$ROOT/sbin/shutdown"
popd > /dev/null

print 3 ":: Now link sinit to /sbin/init or append 'init=/sbin/sinit' in your kernel boot line to complete installation"
