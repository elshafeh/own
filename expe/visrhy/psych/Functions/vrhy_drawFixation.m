function vrhy_drawFixation

global scr wPtr stim

stim.Fix.color          = repmat(scr.black, [1,3]);
JY_VisExptTools('draw_fixation', stim.Fix);