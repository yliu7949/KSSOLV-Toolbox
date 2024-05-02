function encodedJSON = encodeToJSON(this, prettyPrint)
%ENCODETOJSON 递归地处理 size 字段，并编码为 JSON

% 开发者：杨柳
% 版权 2024 合肥瀚海量子科技有限公司

arguments
    this 
    prettyPrint logical = false
end

that = this;
result = processStruct(that);
try
    encodedJSON = jsonencode(result, "PrettyPrint", prettyPrint);
catch ME
    error('KSSOLV:FileManager:Project:JSONEncodeError', ...
      'Error encoding the Project file to JSON: %s', ME.message);
end

function output = processStruct(input)
    % 递归遍历结构体，并处理 size 属性

    % 如果当前结构体包含 children 字段
    if isprop(input, 'children') && ~isempty(input.children)        
        % 对每个 child 进行递归处理
        for i = 1:length(input.children)
            input.children(i) = processStruct(input.children(i));
        end
    else
        % 没有 children 时设定 size 为 data 的维度
        input.size = sprintf('%dx%d', size(input.data, 1), size(input.data, 2));
    end
    
    % 返回处理后的结构体
    output = input;
end
end
