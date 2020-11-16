%Z_Tests

% function cosa = Sento_varagin(A,B,varargin)
% switch (varargin{:})
%     case 'suma'
%         cosa = A + B;
%     case 'resta'
%         cosa = A - B;
%     otherwise
%         cosa = 0;
% end
% end

% function varargout  = Sento(A,B,varargin)
% p = inputParser();
% p.suma = false;
% p.resta = false;
% 
% addParameter (p, 'sento_suma' , nan)
% addParameter (p, 'sento_resta', nan)
% 
% parse (p, varargin{:}
%     ip = p.Results;
%     fprintf( '%16s   %s\n', 'name' , 'value' ) 
%     fprintf( '%16s = %f\n', 'HorizontalArea' , ip.HorizontalArea ) 
%     fprintf( '%16s = %f\n', 'VerticalArea'   , ip.VerticalArea )
%     
%     is_case_1 = isempty( setxor( {'VerticalArea'  ,'OutsideDiameter'}, p.UsingDefaults ));
%     is_case_2 = isempty( setxor( {'VerticalArea'  ,'InsideDiameter' }, p.UsingDefaults ));
%     is_case_3 = isempty( setxor( {'VerticalArea'                    }, p.UsingDefaults ));
%     is_case_4 = isempty( setxor( {'HorizontalArea','OutsideDiameter'}, p.UsingDefaults ));
%     is_case_5 = isempty( setxor( {'HorizontalArea','InsideDiameter' }, p.UsingDefaults ));
%     is_case_6 = isempty( setxor( {'HorizontalArea'                  }, p.UsingDefaults ));
% 
% 
% end
% end


function    varargout = LL_Leitwert_freie_Konvektion_Strahlung( varargin )
    p = inputParser();
    p.KeepUnmatched = false;
    p.CaseSensitive = false;
    p.StructExpand  = false;
    p.PartialMatching = true;
    
    addParameter( p, 'HorizontalArea'   , nan ) % I like NaN as value of 
    addParameter( p, 'VerticalArea'     , nan ) % variables that must not 
    addParameter( p, 'OutsideDiameter'  , nan ) % be used. NaN makes use 
    addParameter( p, 'InsideDiameter'   , nan ) % by mistake obvious.
    
    parse( p, varargin{:} )
    
    ip = p.Results;
    fprintf( '%16s   %s\n', 'name' , 'value' ) 
    fprintf( '%16s = %f\n', 'HorizontalArea' , ip.HorizontalArea ) 
    fprintf( '%16s = %f\n', 'VerticalArea'   , ip.VerticalArea ) 
    fprintf( '%16s = %f\n', 'OutsideDiameter', ip.OutsideDiameter ) 
    fprintf( '%16s = %f\n', 'InsideDiameter' , ip.InsideDiameter ) 
    
    %                             parameters not in the input string                  
    is_case_1 = isempty( setxor( {'VerticalArea'  ,'OutsideDiameter'}, p.UsingDefaults ));
    is_case_2 = isempty( setxor( {'VerticalArea'  ,'InsideDiameter' }, p.UsingDefaults ));
    is_case_3 = isempty( setxor( {'VerticalArea'                    }, p.UsingDefaults ));
    is_case_4 = isempty( setxor( {'HorizontalArea','OutsideDiameter'}, p.UsingDefaults ));
    is_case_5 = isempty( setxor( {'HorizontalArea','InsideDiameter' }, p.UsingDefaults ));
    is_case_6 = isempty( setxor( {'HorizontalArea'                  }, p.UsingDefaults ));
    
    assert( any( [is_case_1,is_case_2,is_case_3,is_case_4,is_case_5,is_case_6] )...
        ,   'abc:def:IllegalInputCombination'                                   ...
        ,   'Your combination of inputs is illegal'                             )
    
    % further calculations
    varargout = { ip, p };
end