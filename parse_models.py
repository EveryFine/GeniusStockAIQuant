#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
解析SQLModel模型文件并提取表结构信息
"""

import ast
import os
import json
from pathlib import Path
from typing import Dict, List, Any

def parse_model_file(file_path: str) -> Dict[str, Any]:
    """解析SQLModel模型文件"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    tree = ast.parse(content)
    
    # 提取docstring和描述
    module_docstring = ast.get_docstring(tree) or ""
    description = ""
    for line in module_docstring.split('\n'):
        if 'Description' in line or 'Description :' in line:
            description = line.split(':', 1)[-1].strip()
            break
    
    # 查找主表类定义
    for node in ast.walk(tree):
        if isinstance(node, ast.ClassDef):
            # 查找table=True的类
            if any(isinstance(item, ast.keyword) and item.arg == 'table' for item in node.keywords):
                fields = {}
                base_class = None
                
                # 查找基类中的字段
                for base in node.bases:
                    if isinstance(base, ast.Name) and 'Base' in base.id:
                        base_class = base.id
                
                # 查找当前类中定义的注解
                for item in node.body:
                    if isinstance(item, ast.Assign):
                        for target in item.targets:
                            if isinstance(target, ast.Name):
                                fields[target.id] = None
                    elif isinstance(item, ast.AnnAssign):
                        if isinstance(item.target, ast.Name):
                            fields[item.target.id] = None
                
                # 从Base类找字段定义
                for item in ast.walk(tree):
                    if isinstance(item, ast.ClassDef) and item.name == base_class:
                        for field_item in item.body:
                            if isinstance(field_item, ast.AnnAssign):
                                if isinstance(field_item.target, ast.Name):
                                    field_name = field_item.target.id
                                    field_info = {
                                        'type': ast.unparse(field_item.annotation),
                                        'description': ''
                                    }
                                    
                                    # 提取 Field 中的 description
                                    if isinstance(field_item.value, ast.Call):
                                        for keyword in field_item.value.keywords:
                                            if keyword.arg == 'description':
                                                field_info['description'] = ast.literal_eval(keyword.value)
                                            elif keyword.arg == 'max_length':
                                                max_len = ast.literal_eval(keyword.value)
                                                field_info['type'] = f"varchar({max_len})"
                                    
                                    fields[field_name] = field_info
                
                # 返回表信息
                return {
                    'table_name': node.name,
                    'description': description,
                    'fields': fields,
                    'file': os.path.basename(file_path)
                }
    
    return None

def extract_all_models(models_dir: str) -> Dict[str, Dict[str, Any]]:
    """提取所有模型文件"""
    models = {}
    
    for file_path in sorted(Path(models_dir).glob('*.py')):
        if file_path.name.startswith('__'):
            continue
        
        try:
            model_info = parse_model_file(str(file_path))
            if model_info:
                models[file_path.stem] = model_info
        except Exception as e:
            print(f"Error parsing {file_path.name}: {e}")
    
    return models

if __name__ == '__main__':
    models_dir = '/Users/zhengshuang/Documents/ProgramingGuide/SourceCode/GithubRepo/everyfine/GeniusStockAIQuant/data/raw/models'
    
    models = extract_all_models(models_dir)
    
    # 输出结果为JSON
    output = json.dumps(models, ensure_ascii=False, indent=2)
    print(output)
    
    # 同时保存为文件
    with open('/tmp/models_info.json', 'w', encoding='utf-8') as f:
        f.write(output)
    
    print(f"\n总共解析 {len(models)} 个模型")
