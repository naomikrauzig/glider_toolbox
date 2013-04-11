function [hfig, haxs, hsct, hcba] = plotTransectVerticalSection(varargin)
%PLOTTRANSECTVERTICALSECTION  Plot vertical section of scatter data from a glider transect.
%
%  Syntax:
%    PLOTTRANSECTVERTICALSECTION(OPTIONS)
%    PLOTTRANSECTVERTICALSECTION(OPT1, VAL1, ...)
%    PLOTTRANSECTVERTICALSECTION(H, OPTIONS)
%    PLOTTRANSECTVERTICALSECTION(H, OPT1, VAL1, ...)
%    [HFIG, HAXS, HSCT, HCBA] = PLOTTRANSECTVERTICALSECTION(...)
%
%  PLOTTRANSECTVERTICALSECTION(OPTIONS) and 
%  PLOTTRANSECTVERTICALSECTION(OPT1, VAL1, ...) generate a new figure with a
%  scatter plot of scalar data collected during a glider transect according to
%  options in string key-value pairs OPT1, VAL1... or in option struct OPTIONS.
%  Allowed options are:
%    XDATA: horizontal coordinate data.
%      Vector of data to be passed as x coordindate to the function SCATTER, 
%      usually distance or time.
%      Default value: []
%    YDATA: vertical coordinate data.
%      Vector of data to be passed as y coordindate to the function SCATTER,
%      usually pressure or depth.
%      Default value: []
%    CDATA: measured variable data.
%      Vector of data to be passed as color coordindate to the function SCATTER.
%      Default value: []
%    XLABEL: horizontal axis label data.
%      Struct defining x label properties. Label's text is in property 'String'.
%      Default value: struct()
%    YLABEL: vertical axis label data.
%      Struct defining y label properties. Label's text is in property 'String'.
%      Default value: struct()
%    CLABEL: color bar label data.
%      Struct defining color bar label properties. Label's text is in property 
%      'String'. Actually this will be the colorbar's child object 'Title'.
%      Default value: struct()
%    TITLE: axes title data.
%      Struct defining axes title properties. Title's text is in property 
%      'String'.
%      Default value: struct()
%    LOGSCALE: use logarithmic color scale instead of linear scale.
%      Boolean specifying whether color scale should be logarithmic instead of
%      linear. There is no built-in graphic option for logarithmic color scaling
%      so the effect is produced hacking the color data and the color bar ticks.
%      Default value: false
%    DATETICKS: use date formatted tick labels for selected axes.
%      Substring of 'xyz' specifying which axes should be labeled with date
%      formatted ticks using function DATETICKS.
%      Default value: ''
%    AXSPROPS: extra axis properties.
%      Struct of axis properties to be set for the plot axes with function SET.
%      Default value: struct()
%    FIGPROPS: extra figure properties.
%      Struct of figure properties to be set for the figure with function SET.
%      Default value: struct()
%
%  PLOTTRANSECTVERTICALSECTION(H, ...) does not create a new figure, but plots 
%  to figure given by figure handle H.
%  
%  [HFIG, HAXS, HSCT, HCBA] = PLOTTRANSECTVERTICALSECTION(...) returns handles
%  for the figure, axes, scatter group, and color bar in HFIG, HAXS, HSCT and
%  HCBA, respectively.
%
%  Notes:
%
%  Examples:
%    [hfig, haxs, hsct, hcba] = ...
%      plotTransectVerticalSection( gcf, ...
%        'xdata', now+1*rand(100,1), 'xlabel', struct('String', 'x'), ...
%        'ydata', rand(100,1), 'ylabel', struct('String', 'y'), ...
%        'cdata', 10.^(3*rand(100,1)), 'clabel', struct('String', 'c'), ...
%        'logscale', true, 'dateticks', 'x', ...
%        'title', struct('String', 'Random scatter plot'), ...
%        'axsprops', struct('XGrid', 'on', 'YGrid', 'on', 'PlotBoxAspectRatio', [2 1 1]), ...
%        'figprops', struct('Name', 'Vertical section example') )
%
%  See also:
%    SCATTER
%    COLORBAR
%    DATETICK
%    SET
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  % No argument number checking since any number of arguments is allowed.

  %% Set plot options and default values.
  options = struct();
  options.xdata = [];
  options.ydata = [];
  options.cdata = [];
  options.xlabel = struct();
  options.ylabel = struct();
  options.clabel = struct();
  options.title = struct();
  options.logscale = false;
  options.dateticks = '';
  options.axsprops = struct();
  options.figprops = struct();
  
  
  %% Get optional figure handle and option arguments.
  if (nargin > 0) && isscalar(varargin{1}) && ishghandle(varargin{1})
    args = varargin(2:end);
    hfig = figure(varargin{1});
  else
    args = varargin;
    hfig = figure();
  end
  
  
  %% Get options from extra arguments.
  % Parse option key-value pairs in any accepted call signature.
  if isscalar(args) && isstruct(args{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    option_key_list = fieldnames(args{1});
    option_val_list = struct2cell(args{1});
  elseif mod(numel(args), 2) == 0
    % Options passed as key-value argument pairs.
    option_key_list = args(1:2:end);
    option_val_list = args(2:2:end);
  else
    error('glider_toolbox:plotTransectVerticalSection:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:plotTransectVerticalSection:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set figure properties.
  set(hfig, options.figprops);
  
  
  %% Initialize all plot elements.
  haxs = gca();
  hsct = scatter(haxs, [], [], [], [], 'fill');
  hcba = colorbar('SouthOutside');
  haxstit = title(haxs, []);
  haxsxlb = xlabel(haxs, []);
  haxsylb = ylabel(haxs, []);
  hcbatit = get(hcba, 'XLabel');
  
  
  %% Set properties of plot elements.
  if options.logscale
    % Hack to plot a color bar with logarithmic scale and linear ticks.
    % This code should go after colormap call, otherwise colormap resets ticks.
    set(hsct, ...
        'XData', options.xdata, 'YData', options.ydata, 'CData', log10(options.cdata));
    crange = log10([min(options.cdata)  max(options.cdata)]);
    ctick = log10((1:9)' * 10 .^ (floor(crange(1)) : floor(crange(2))));
    ctick = ctick(crange(1) <= ctick & ctick <= crange(2));
    ctick_mask = ( rem(ctick, 1) == 0 );
    if sum(ctick_mask) == 1
      ctick_mask([1 end]) = true;
    end
    ctick_label = cellstr(num2str(10.^ctick(:)));
    ctick_label(~ctick_mask) = {''};
    drawnow(); % Hack to force plot update before setting color axis properties.
    set(hcba, 'XTick', ctick, 'XTickLabel', ctick_label);
  else
    set(hsct, ...
        'XData', options.xdata, 'YData', options.ydata, 'CData', options.cdata);
  end
  for a = 'xyz'
    if ismember(a, options.dateticks)
      arange = range(get(haxs, [a 'lim']));
      if arange > 365
        datetick_format = 'yyyy mmm';
      elseif arange > 2
        datetick_format = 'mmm dd';
      else
        datetick_format = 'HH:mm:ss';
      end
      datetick(a, datetick_format, 'keeplimits');
    end
  end
  set(haxs, options.axsprops);
  set(haxstit, options.title);
  set(haxsxlb, options.xlabel);
  set(haxsylb, options.ylabel);
  set(hcbatit, options.clabel);

end
