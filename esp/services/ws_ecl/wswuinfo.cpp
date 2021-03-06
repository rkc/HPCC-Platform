#include "jliball.hpp"
#include "wswuinfo.hpp"
#include "fileview.hpp"

WsWuInfo::WsWuInfo(const char *wuid_, const char *qset, const char *qname, const char *user, const char *pw) :
    wuid(wuid_), qsetname(qset), queryname(qname), username(user), password(pw)
{
    Owned<IWorkUnitFactory> wf = getWorkUnitFactory();
    if (!wuid.length() && qsetname.length() && queryname.length())
    {
        Owned<IPropertyTree> qstree = getQueryRegistry(qsetname.sget(), true);
        if (qstree)
        {
            VStringBuffer xpath("Query[@id=\"%s\"]", queryname.sget());
            IPropertyTree *query = qstree->queryPropTree(xpath.str());
            if (query)
                wuid.set(query->queryProp("@wuid"));
            else
                throw MakeStringException(-1, "Query %s not found in QuerySet %s", queryname.sget(), qsetname.sget());
        }
        else
            throw MakeStringException(-1, "QuerySet %s not found", qsetname.sget());
    }
        
    if (wuid.length())
    {
        wu.setown(wf->openWorkUnit(wuid.sget(), false));
        if (!wu)
            throw MakeStringException(-1, "Could not open workunit: %s", wuid.sget());
    }
    else
        throw MakeStringException(-1, "Workunit not specified");
}

bool WsWuInfo::getWsResource(const char *name, StringBuffer &out)
{
    if (strieq(name, "SOAP"))
    {
        out.appendf("<message name=\"%s\">", queryname.sget());
        IConstWUResultIterator &vars = wu->getVariables();
        Owned<IResultSetFactory> resultSetFactory(getResultSetFactory(username, password));
        ForEach(vars)
        {
            IConstWUResult &var = vars.query();
            SCMStringBuffer varname;
            var.getResultName(varname);
            int seq = var.getResultSequence();

            WUResultFormat fmt = var.getResultFormat();

            SCMStringBuffer eclschema;
            var.getResultEclSchema(eclschema);

            SCMStringBuffer s;
            Owned<IResultSetMetaData> meta = resultSetFactory->createResultSetMeta(&var);

            if (!var.isResultScalar())
            {
                meta->getXmlSchema(s, false);
                out.appendf("<part name=\"%s\" type=\"tns:XmlDataSet\" />", varname.str());
            }
            else
            {
                meta->getColumnEclType(s, 0);
                DisplayType dt = meta->getColumnDisplayType(0);
                StringAttr ptype;
                switch (dt)
                {
                case TypeBoolean:
                    ptype.set("xsd:boolean");
                    break;
                case TypeInteger:
                    ptype.set("xsd:integer");
                    break;
                case TypeUnsignedInteger:
                    ptype.set("xsd:integer");
                    break;
                case TypeReal:
                    ptype.set("xsd:real");
                    break;
                case TypeSet:
                case TypeDataset:
                case TypeData:
                    ptype.set("tns:XmlDataSet");
                    break;
                case TypeUnicode:
                case TypeString:
                    ptype.set("xsd:string");
                    break;
                case TypeUnknown:
                case TypeBeginIfBlock:
                case TypeEndIfBlock:
                case TypeBeginRecord:
                default:
                    ptype.set("xsd:string");
                    break;
                }

                out.appendf("<part name=\"%s\" type=\"%s\" />", varname.str(), ptype.sget());
            }

        }
        out.append("</message>");
    }

    return true;
}

IPropertyTree *WsWuInfo::queryParamInfo()
{
    if (!paraminfo)
    {
        StringBuffer xml;
        if (getWsResource("SOAP", xml))
            paraminfo.setown(createPTreeFromXMLString(xml.str()));
    }
    return paraminfo.get();
}


void WsWuInfo::addOutputSchemas(StringBuffer &schemas, IConstWUResultIterator *results, const char *tag)
{
    ForEach(*results)
    {
        StringBuffer s;
        getSchemaFromResult(s, results->query());
        SCMStringBuffer resultName;
        results->query().getResultName(resultName);
        StringBuffer sname =resultName.s.str();
        sname.replace(' ', '_');
        int seq = results->query().getResultSequence();
        schemas.appendf("<%s sequence=\"%d\" name=\"%s\" sname=\"%s\">%s</%s>", tag, seq, resultName.str(), sname.str(), s.str(), tag);
    }
}

void WsWuInfo::addInputSchemas(StringBuffer &schemas, IConstWUResultIterator *results, const char *tag)
{
    ForEach(*results)
    {
        if (!results->query().isResultScalar())
        {
            StringBuffer s;
            getSchemaFromResult(s, results->query());
            SCMStringBuffer resultName;
            results->query().getResultName(resultName);
            StringBuffer sname =resultName.s.str();
            sname.replace(' ', '_');

            int seq = results->query().getResultSequence();
            schemas.appendf("<%s sequence=\"%d\" name=\"%s\" sname=\"%s\">%s</%s>", tag, seq, resultName.str(), sname.str(), s.str(), tag);
        }
    }
}

void WsWuInfo::getSchemaFromResult(StringBuffer &schema, IConstWUResult &res)
{
//  if (!res.isResultScalar())
//  {
        StringBufferAdaptor s(schema);
        
        Owned<IResultSetFactory> resultSetFactory(getResultSetFactory(username, password));
        Owned<IResultSetMetaData> meta = resultSetFactory->createResultSetMeta(&res);
        meta->getXmlSchema(s, true);
        const char *finger=schema.str();
        while (finger && strncmp(finger, "<xs:schema", 10))
            finger++;
//  }
}

void WsWuInfo::getInputSchema(StringBuffer &schema, const char *name)
{
    Owned<IConstWUResult> res =  wu->getResultByName(name);
    getSchemaFromResult(schema, *res);
}

void WsWuInfo::getOutputSchema(StringBuffer &schema, const char *name)
{
    Owned<IConstWUResult> res =  wu->getResultByName(name);
    getSchemaFromResult(schema, *res);
}


void WsWuInfo::updateSchemaCache()
{
    if (!schemacache.length())
    {
        schemacache.append("<SCHEMA>");

        Owned<IConstWUResultIterator> inputs = &wu->getVariables();
        addInputSchemas(schemacache, inputs, "Input");

        Owned<IConstWUResultIterator> results = &wu->getResults();
        addOutputSchemas(schemacache, results, "Result");
        
        schemacache.append("</SCHEMA>");
    }
}

void WsWuInfo::getSchemas(StringBuffer &schemas)
{
    updateSchemaCache();
    schemas.append(schemacache);
}

IPropertyTreeIterator *WsWuInfo::getInputSchemas()
{
    if (!xsds)
    {
        updateSchemaCache();
        if (schemacache.length())   
            xsds.setown(createPTreeFromXMLString(schemacache.str()));
    }

    return (xsds) ? xsds->getElements("Input") : NULL;
}

IPropertyTreeIterator *WsWuInfo::getResultSchemas()
{
    if (!xsds)
    {
        updateSchemaCache();
        if (schemacache.length())   
            xsds.setown(createPTreeFromXMLString(schemacache.str()));
    }

    return (xsds) ? xsds->getElements("Result") : NULL;
}
