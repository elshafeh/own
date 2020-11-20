%Testing dipole position in volume

%Plot the dipole

load standard_bem
elec=ft_read_sens('standard_1020.elc');

cortex_vol=[];
cortex_vol.bnd=vol.bnd(3);
cortex_vol.cond=vol.cond(3);
cortex_vol.mat=vol.mat;
cortex_vol.type='dipoli';
cortex_vol.unit='mm';
dipole_pos=[0 -80 30];
ft_plot_vol(cortex_vol,'facealpha',0,'edgealpha',0.25);
hold on
ft_plot_dipole(dipole_pos,dipole_momentum,'color','r','unit','mm','diameter',5)
