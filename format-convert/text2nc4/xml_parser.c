/***********************************************************************
* Filename : xml_parser.c
* Create : Chen Cheng 2011-04-19
* Description: 
* Modified   : 
* Revision of last commit: $Rev$ 
* Author of last commit  : $Author$ $date$
* licence :
$licence$
* **********************************************************************/

#include <stdio.h>
#include <string.h>
#include <libxml/xmlreader.h>

#include "xml_parser.h"

extern struct att_xml_t att_list[ATT_MAX_NUM];
extern struct var_xml_t var_list[VAR_MAX_NUM];
extern struct dim_xml_t dim_list[DIM_MAX_NUM];
extern int natts;
extern int nvars;
extern int ndims;

void parse_dimension(struct dim_xml_t *dim, xmlNodePtr cur) {
	dim->name = xmlGetProp(cur, "name");
	dim->length = xmlGetProp(cur, "length");

	//printf("dimension %s = %s\n", dim.name, dim.length);
	return;
}

void parse_attribute(struct att_xml_t *att, xmlNodePtr cur) {
	//att->name = malloc(10);
	//strcpy(att->name, xmlGetProp(cur, "name"));
	att->name = xmlGetProp(cur, "name");
	//printf("att->name %d\n", strlen(att->name));
	att->value = xmlGetProp(cur, "value");
	//printf("att->value %d\n", strlen(att->value));

	//printf("attribute %s = %s\n", att.name, att.value);
	
	return;
}

void parse_variable(struct var_xml_t *var, xmlNodePtr cur) {

	var->name = xmlGetProp(cur, "name");
	var->shape = xmlGetProp(cur, "shape");
	var->type = xmlGetProp(cur, "type");
	var->natts = 0;
	//property = xmlGetProp(cur, "property");

	//printf("variable %s %s %s %s\n", var.name, var.shape, var.type);

	cur = cur->xmlChildrenNode;
	while(cur != NULL) {
		if(!(xmlStrcmp(cur->name, (const xmlChar *)"attribute")))
			parse_attribute(&var->att_list[var->natts++], cur);
		cur = cur->next;
	}
	return;
}

int parser_xml_file(char *path){

	xmlDocPtr	doc;
	xmlNodePtr	cur;

	doc = xmlParseFile(path);

	if(doc == NULL) {
		fprintf(stderr, "Document not parsed success\n");
		exit(1);
	}

	cur = xmlDocGetRootElement(doc);
	if(cur == NULL) {
		fprintf(stderr, "empty cocument\n");
		xmlFreeDoc(doc);
		exit(1);
	}

	//printf("root name: %s\n", cur->name);
	
	cur = cur->xmlChildrenNode;
	while(cur != NULL) {
		//printf("name %s\n", cur->name);
		if(!(xmlStrcmp(cur->name, (const xmlChar *)"dimension")))
			parse_dimension(&dim_list[ndims++], cur);
		if(!(xmlStrcmp(cur->name, (const xmlChar *)"variable")))
			parse_variable(&var_list[nvars++], cur);
		if(!(xmlStrcmp(cur->name, (const xmlChar *)"attribute")))
			parse_attribute(&att_list[natts++], cur);
		
		cur = cur->next;
	}

	return 0;
}
