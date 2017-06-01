Role Name
=========

Setup a basic i3wm setup for users.

Requirements
------------

To run the role requires users to be defined, as they are for the User role.

Role Variables
--------------

Dependencies
------------

User role to ensure the users i3 should be configured for exist.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - {i3wm, vars: }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
