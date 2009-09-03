;;; pcmpl-ssh.el --- functions for completing SSH hostnames

;; Copyright (C) 2007 Phil Hagelberg

;; Author: Phil Hagelberg <technomancy@gmail.com>
;; URL: http://www.emacswiki.org/cgi-bin/wiki/pcmpl-ssh.el
;; Version: 0.2
;; Created: 2007-12-02
;; Keywords: shell completion ssh
;; EmacsWiki: PcompleteSSH

;; This file is NOT part of GNU Emacs.

;; Last-Updated: Sun Dec 04 11:51:06 2007 PST
;; By: Phil Hagelberg
;; Update #: 2

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This will allow eshell to autocomplete SSH hosts from the list of
;; known hosts in your ~/.ssh/known_hosts file. Note that newer
;; versions of ssh hash the hosts by default to prevent Island-hopping
;; SSH attacks. (https://itso.iu.edu/Hashing_the_OpenSSH_known__hosts_File)
;; You can disable this by putting the following line in your ~/.ssh/config
;; file following the "Host *" directive:

;; HashKnownHosts no

;; Note that this will make you vulnerable to the Island-hopping
;; attack described in the link above if you allow key-based
;; passwordless logins and your account is compromised.

;;; Code:

(require 'pcomplete)
(require 'executable)

;;;###autoload
(defun pcomplete/ssh ()
  "Completion rules for the `ssh' command."
  (pcomplete-opt "1246AaCfgKkMNnqsTtVvXxYbcDeFiLlmOopRSw" nil t)
  (pcomplete-here (pcmpl-ssh-hosts)))

;;;###autoload
(defun pcomplete/scp ()
  "Completion rules for the `scp' command.

Includes files as well as host names followed by a colon."
  (pcomplete-opt "1246BCpqrvcFiloPS")
  (while t (pcomplete-here (append (pcomplete-all-entries)
                                   (mapcar (lambda (host) (concat host ":")) (pcmpl-ssh-hosts))))))

(defvar pcmpl-ssh-known-hosts-file "~/.ssh/known_hosts" "ssh known hosts")

(defun pcmpl-ssh-hosts ()
  "Return a list of hosts found in `pcmpl-ssh-known-hosts-file'."
  (when (and pcmpl-ssh-known-hosts-file
             (file-readable-p pcmpl-ssh-known-hosts-file))
    (with-temp-buffer
      (insert-file-contents-literally pcmpl-ssh-known-hosts-file)
      (let (ssh-hosts-list)
        (while (re-search-forward "^ *\\([-.[:alnum:]]+\\)[, ]" nil t)
          (add-to-list 'ssh-hosts-list (match-string 1))
          (while (and (looking-back ",")
                      (re-search-forward "\\([-.[:alnum:]]+\\)[, ]"
                                         (line-end-position) t))
            (add-to-list 'ssh-hosts-list (match-string 1))))
        ssh-hosts-list))))

(provide 'pcmpl-ssh)
;;; pcmpl-ssh.el ends here
