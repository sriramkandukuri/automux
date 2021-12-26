# Automux with python

To build an automux framework using python and libtmux

## Gaps in libtmux

- pipe-pane - try executing pipepane for allowing expect functionality
- capture-pane for logging
- clear-history in panes


## Requirements

- better name : Automation Framework Using Python and TMUX
- Use pytest
    - for html reports
    - pass success
    - test plan creation
- Use sriramkandukuri/libtmux
- create tmux server -> session -> window(s) -> panes if not exist
- pytest should not create objects for each test. singleton automux object through out the test
- 

## TODO

- [ ] create github project and add tasks to work with Abhilash
- [ ] libtmux modifications
    - [ ] Add support for pipe-pane
    - [ ] Check and add support for clear-history
    - [ ] add capability to set pane level params ref @automux_panename in automux shell based implementation
- [ ] automux framework
    - [ ] pytest study and usage
    - [ ] define and use automux singleton
    - [ ] config file support to create session window and panes hierarchy with defaults
    - [ ] make pane names accessible globally
    

## Maintenance

- create separate project Automux

