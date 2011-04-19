/***********************************************************************
* Filename : xml_parser.h
* Create : Chen Cheng 2011-04-19
* Description: 
* Modified   : 
* Revision of last commit: $Rev$ 
* Author of last commit  : $Author$ $date$
* licence :
$licence$
* **********************************************************************/

#define DIM_MAX_NUM 5
#define ATT_MAX_NUM 20
#define VAR_MAX_NUM 5

struct dim_xml_t {
	char *name;
	char *length;
};

struct att_xml_t {
	char *name;
	char *value;
};

struct var_xml_t {
	char *name;
	char *shape;
	char *type;
	int natts;
	struct att_xml_t att_list[ATT_MAX_NUM];
};

int parser_xml_file(char *path);

/*struct dim_list_t{
	dim_xml_t *head;
	dim_xml_t *tail;
	dim_xml_t *next;
};

struct att_list_t{
	att_xml_t *head;
	att_xml_t *tail;
	att_xml_t *next;
};

struct var_list_t{
	var_xml_t *head;
	att_xml_t *tail;
	var_xml_t *next;
};*/
