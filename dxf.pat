#include <std/mem.pat>
#include <std/core.pat>
#include <std/io.pat>

fn isNotBreak(u128 address){
	return std::mem::read_unsigned(address, 1) != 0x0A;
};

struct Object{
	char group[while(isNotBreak($))];
	padding[1];
	char data[while(isNotBreak($))];
	padding[1];
};

fn objectGroup(u128 address){
	Object o @ address;
	return o.group;
};

fn objectData(u128 address){
	Object o @ address;
	return o.data;
};

struct Variable{
	Object name;
	Object values[while((objectData($) != "ENDSEC") && (objectGroup($) != name.group))];

	// verify if next is not a var, so it not ends up in the current array
	if(objectData($) == "ENDSEC")
		break;
};

fn VariableFormat(Variable var){
	str arr = var.name.data + ": ";
	u32 s = std::core::member_count(var.values);

	if(s == 0){
		arr = arr + "[]";
	}
	else if(s == 1){
		arr = arr + var.values[0].data;
	}
	else{
		arr = arr + "{";
		for(u32 i = 0, i < s, i = i + 1){
			arr = arr + var.values[i].data + ", ";
		}
		arr = arr + "}";
	}
	return arr;
};

struct Section{
	Object newSectionTag [[hidden]];
	Object section [[inline]];
	Variable variables[10000] [[format_entries("VariableFormat")]];
	Object endSectionTag [[hidden]];
};

struct Dxf{
	Object customInfo [[inline]];
	Section header;
	Section classes;
	Section tables;
	Section blocks;
	Section entities;
	Section objects;
};

Dxf dxf @ 0x00;
