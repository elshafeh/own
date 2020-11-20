classdef obob_testOBOB_parcellation < matlab.unittest.TestCase
  %TESTOBOB_WHOLE_FLOW Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    old_warning
  end %properties
  
  methods(TestClassSetup)
    function loadData(testCase)
      testCase.old_warning = warning;
      warning off;
      addpath(fullfile(fileparts(mfilename('fullpath')), '../../../'));
      cfg = [];
      cfg.package.svs = true;
      obob_init_ft(cfg);
      
      global ft_default
      ft_default.showcallinfo = 'no';
      ft_default.trackcallinfo = 'no';
      
    end %function
  end %methods
  
  methods(TestClassTeardown)
    function restore_warning(testCase)
      warning(testCase.old_warning);
    end %function
  end %methods
  
  methods(Test)
    function test_parcels(testCase)
      results_fname = 'svs_parcel_results_170620.mat';
      testfolder = 'data';
      
      load(fullfile(testfolder, 'data_preproc.mat'));
      load(fullfile(testfolder, 'headmodel.mat'));
      load(fullfile(testfolder, 'test_mri_seg.mat'));
      
      cfg = [];
      cfg.resolution = 15e-3;
      
      parcellation = obob_svs_create_parcellation(cfg);
      
      data.grad = ft_convert_units(data.grad, 'm');
      mni_grid = ft_convert_units(mni_grid, 'm');
      
      cfg = [];
      cfg.latency = [0 .3];
      
      data = ft_selectdata(cfg, data);
      
      cfg = [];
      cfg.mri = mri;
      cfg.grid.warpmni = 'yes';
      cfg.grid.template = parcellation.template_grid;
      cfg.grid.nonlinear = 'yes';
      cfg.grid.unit = 'm';
      
      subject_grid = ft_prepare_sourcemodel(cfg);
      
      cfg = [];
      cfg.grid = subject_grid;
      cfg.vol = vol;
      
      lf = ft_prepare_leadfield(cfg, data);
      
      cfg = [];
      cfg.grid = lf;
      cfg.parcel = parcellation;
      cfg.lpfilter = 'yes';
      cfg.lpfreq = 35;
      cfg.fixedori = 'yes';
      
      svs_parcel_th = obob_svs_beamtrials_lcmv(cfg, data);
      
      if ~exist(fullfile(testfolder, results_fname))
        save(fullfile(testfolder, results_fname), 'svs_parcel_th');
      end %if
      
      results = load(fullfile(testfolder, results_fname));
      
      testCase.assertEqual(obob_rm_cfg(svs_parcel_th), obob_rm_cfg(results.svs_parcel_th));
    end %function
  end %methods
  
end

