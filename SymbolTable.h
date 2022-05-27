#ifndef COMPILER_SYMBOLTABLE_H
#define COMPILER_SYMBOLTABLE_H

#include "ScopeTable.h"

class SymbolTable
{
    ScopeTable *currentScope;
    int size;
    int count;

public:
    SymbolTable(int s)
    {
        this->size = s;
        this->count = 1;
        this->currentScope = new ScopeTable(size);
    }

    void setCurrentScope(ScopeTable *p)
    {
        this->currentScope = p;
    }

    ScopeTable *getCurrentScope()
    {
        return this->currentScope;
    }

    int getCurrentScopeID()
    {
        return currentScope->getID();
    }

    void EnterScope()
    {
        count++;
        currentScope->increaseChildrenNum(1);
        ScopeTable *newScopeTable = new ScopeTable(this->size, currentScope);
        currentScope = newScopeTable;
        cout << "New ScopeTable with id " << currentScope->getTableID() << " created";
        cout << endl;
    }

    void ExitScope()
    {
        ScopeTable *temp = currentScope;
        currentScope = temp->getParentScope();
        delete temp;
        cout << "ScopeTable with id " << temp->getTableID() << " removed";
        cout << endl;
    }

    bool Insert(std::string s, std::string type)
    {
        if (currentScope->Insert(s, type))
            return true;
        return false;
    }

    bool Remove(std::string s)
    {
        if (currentScope->Delete(s))
            return true;

        cout << "Not found";
        cout << endl;

        return false;
    }

    SymbolInfo *LookUp(std::string name)
    {
        ScopeTable *temp = currentScope;
        SymbolInfo *symbol;

        while (temp != NULL)
        {
            symbol = temp->LookUp(name);
            if (symbol != NULL)
                return symbol;
            temp = temp->getParentScope();
        }

        cout << "Not found";
        cout << endl;

        return NULL;
    }

    void printCurrentScopeTable()
    {
        currentScope->Print();
    }

    void printAllScopeTable()
    {
        ScopeTable *temp = currentScope;
        while (temp != NULL)
        {
            temp->Print();
            temp = temp->getParentScope();
        }
    }

    ~SymbolTable()
    {
        ScopeTable *p, *q;
        p = currentScope;

        while (p != NULL)
        {
            q = p->getParentScope();
            delete p;
            p = q;
        }
        delete p;
        delete q;
    }
};

#endif
