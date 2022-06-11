#ifndef COMPILER_SYMBOLINFO_H
#define COMPILER_SYMBOLINFO_H

#include <string>

using namespace std;

class SymbolInfo
{
    string name;
    string type;
    SymbolInfo *next;

public:
    SymbolInfo()
    {
        this->name = "";
        this->type = "";
        this->next = NULL;
    }

    SymbolInfo(string symbolName, string symbolType, SymbolInfo *nextPointer = NULL)
    {
        this->name = symbolName;
        this->type = symbolType;
        this->next = nextPointer;
    }

    string getName() { return this->name; }
    void setName(string newSymbolName) { this->name = newSymbolName; }
    string getType() { return this->type; }
    void setType(string newSymbolType) { this->type = newSymbolType; }
    SymbolInfo *getNextSymbolInfo() { return this->next; }
    void setNextSymbolInfo(SymbolInfo *newNextChainingPointer) { this->next = newNextChainingPointer; }

    ~SymbolInfo()
    {
        // default destructor function
    }
};

#endif