#ifndef COMPILER_SCOPETABLE_H
#define COMPILER_SCOPETABLE_H

#include "SymbolInfo.h"
#include <iostream>

using namespace std;

class ScopeTable
{
    SymbolInfo **table;
    ScopeTable *parentScope;
    int bucketSize, id, children;
    std::string tableID;

public:
    ScopeTable(int n, ScopeTable *parent = NULL)
    {
        bucketSize = n;
        children = 0;
        if (parent != NULL)
        {
            id = parent->getChildrenNum() + 1;
            tableID = parent->getTableID() + "." + std::to_string(id);
        }
        else
        {
            id = 1;
            tableID = std::to_string(id);
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

    void setChildrenNum(int n) { this->children = n; }

    void increaseChildrenNum(int n) { this->children += n; }

    void decreaseChildrenNum(int n) { this->children -= n; }

    void setID(int n)
    {
        this->id = n;
        std::string pTableID = this->parentScope->getTableID();
        this->tableID += pTableID + "." + std::to_string(id);
    }

    void setTableID(std::string s) { this->tableID = s; }

    ScopeTable *getParentScope() { return this->parentScope; }

    void setParentScope(ScopeTable *p)
    {
        this->parentScope = p;
        std::string pID = p->getTableID();
        this->id = p->getChildrenNum()+1;
        p->setChildrenNum(id);
        this->tableID = pID + "." + std::to_string(id);
    }

    bool Insert(std::string name, std::string type)
    {
        int index = hashFunc(name);

        // if the bucket is blank
        if (table[index]->getName() == "")
        {
            table[index]->setName(name);
            table[index]->setType(type);
            return true;
        }

        // collision occurred
        else
        {
            SymbolInfo *root = table[index];
            while (root->getNextSymbolInfo() != NULL)
            {
                if (root->getName() == name)
                {
                    if (root->getType() == type)
                    {
                        std::string s = name + " already exists in current ScopeTable\n";
                        return false;
                    }
                }
                root = root->getNextSymbolInfo();
            }

            // if root is at level-0
            if (root->getNextSymbolInfo() == NULL && root->getName() == name)
            {
                // duplicate found at level 0
                if (root->getType() == type)
                {
                    std::string s = name + " already exists in current ScopeTable\n";
                    return false;
                }
            }

            root = table[index];
            SymbolInfo *newSymbolInfo = new SymbolInfo(name, type, NULL);

            while (root->getNextSymbolInfo() != NULL)
            {
                root = root->getNextSymbolInfo();
            }
            root->setNextSymbolInfo(newSymbolInfo);
            return true;
        }
    }

    SymbolInfo *LookUp(std::string symbol)
    {
        int index = hashFunc(symbol);
        SymbolInfo *head = table[index];

        if (head->getName() == "")
        {
            return NULL;
        }
        else
        {
            while (head != NULL)
            {
                if (head->getName() == symbol)
                {
                    return head;
                }

                head = head->getNextSymbolInfo();
            }
        }
        return NULL;
    }

    bool Delete(std::string name)
    {
        int index = hashFunc(name);

        SymbolInfo *head = table[index];
        SymbolInfo *temp, *p, *q;

        if (head == NULL)
        {
            return false;
        }
        else if (head->getNextSymbolInfo() == NULL)
        {
            if (head->getName() == name)
            {
                head->setName("");
                head->setType("");
                return true;
            }
            else
                return false;
        }
        else if (head->getNextSymbolInfo() != NULL)
        {
            if (head->getName() == name)
            {
                temp = table[index];
                table[index] = table[index]->getNextSymbolInfo();

                temp->setNextSymbolInfo(NULL);
                delete temp->getNextSymbolInfo();
                delete temp;
                return true;
            }
            else
            {
                p = head;
                q = head->getNextSymbolInfo();

                while (q != NULL)
                {
                    if (q->getName() == name)
                    {
                        p->setNextSymbolInfo(q->getNextSymbolInfo());
                        q->setNextSymbolInfo(NULL);
                        delete q->getNextSymbolInfo();
                        delete q;
                        return true;
                    }
                    else
                    {
                        p = q;
                        q = q->getNextSymbolInfo();
                    }
                }
                return false;
            }
        }
    }

    void Print()
    {
        std::cout << std::endl
                  << "ScopeTable # " << this->getTableID() << std::endl;
        for (int i = 0; i < bucketSize; i++)
        {
            std::cout << i << " --> ";
            if (table[i]->getNextSymbolInfo() == NULL)
            {
                if (table[i]->getName() != "")
                    std::cout << " < " << table[i]->getName() << " : " << table[i]->getType() << "> ";
            }
            else
            {
                SymbolInfo *temp = table[i];
                while (temp != NULL)
                {
                    std::cout << " < " << temp->getName() << " : " << temp->getType() << "> ";
                    temp = temp->getNextSymbolInfo();
                }
            }
            std::cout << " " << std::endl;
        }
        std::cout << std::endl;
    }

    ~ScopeTable()
    {
        for (int i = 0; i < bucketSize; i++)
        {
            delete table[i]->getNextSymbolInfo();
            delete table[i];
        }
        delete[] table;
    }
};

#endif
