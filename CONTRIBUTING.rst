============
Contributing
============

Thank you for your help!

Cuckoo Linux is in development, so things change a lot. Open an issue first, so we can talk about your idea.

License
=======

All contributions use the GPL-3.0-or-later license. See `LICENSE <LICENSE>`_.

Before you send a pull request
==============================

1. Keep the change small and simple.
2. Use the ``.editorconfig`` file in your text editor.
3. Check the scripts with shellcheck:

   .. code:: sh

      make check

4. Build the ``cuckoo`` profile and boot the ISO with Secure Boot on and off.

Never add your ``MOK.key`` to the repository.
