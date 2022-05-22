#include <SymbolInfo.h>

class ScopeTable
{
    SymbolInfo **table;
    ScopeTable *parentScope;
    int bucketSize, id, children;
    std::string tableID;

public:
    ScopeTable(int n, ScopeTable *parent = 0)
    {
        bucketSize = n;
        children = 0;
        if (parent != NULL)
        {
            id = parent->getChildrenNum() + 1;
            tableID = parent->getTableID() + "." + to_string(id);
        }
        else
        {
            id = 0;
            tableID = to_string(id);
        }

        table = new SymbolInfo *[n];
        for (int i = 0; i < n; i++)
        {
            table[i] = new SymbolInfo();
        }
    }

    int hashFunc(std::string s) const
    {
        int sum = 0;
        for (int i = 0; i < s.length(); i++)
        {
            sum += s.at(i);
        }
        return sum % bucketSize;
    }

    int getChildrenNum() { return children; }
    int getID() { return id; }
    std::string getTableID() { return tableID; }

    ~ScopeTable()
    {
        
    }
};