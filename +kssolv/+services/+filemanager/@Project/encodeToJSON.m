function encodedJSON = encodeToJSON(this, prettyPrint)
%ENCODETOJSON 递归地处理 size 字段，并编码为 JSON
% 用于 Project Browser

% 开发者：杨柳
% 版权 2024 合肥瀚海量子科技有限公司

arguments
    this 
    prettyPrint logical = false
end

try
    encodedJSON = jsonencode(this, "PrettyPrint", prettyPrint);
catch ME
    error('KSSOLV:FileManager:Project:JSONEncodeError', ...
      'Error encoding the Project file to JSON: %s', ME.message);
end

end

