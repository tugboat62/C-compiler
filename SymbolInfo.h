#include <string>

class SymbolInfo
{
    std::string name;
    std::string type;
    SymbolInfo *next;

public:
    SymbolInfo()
    {
        this->name = "";
        this->type = "";
        this->next = NULL;
    }

    SymbolInfo(std::string symbolName, std::string symbolType, SymbolInfo *nextPointer = NULL)
    {
        this->name = symbolName;
        this->type = symbolType;
        this->next = nextPointer;
    }

    std::string getName() { return this->name; }
    void setName(std::string newSymbolName) { this->name = newSymbolName; }
    std::string getType() { return this->type; }
    void setType(std::string newSymbolType) { this->type = newSymbolType; }
    SymbolInfo *getNextSymbolInfo() { return this->next; }
    void setNextSymbolInfo(SymbolInfo *newNextChainingPointer) { this->next = newNextChainingPointer; }

    ~SymbolInfo()
    {
        delete next;
    }
};