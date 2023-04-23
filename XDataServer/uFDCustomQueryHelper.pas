{*******************************************************************************}
{                                                                               }
{ Copyright © 2022                                                              }
{   FlixEngineering, LLC                                                        }
{   Email : info@flixengineering.com                                            }
{   Web : https://www.flixengineering.com                                       }
{                                                                               }
{ The source code is given as is. The author is not responsible                 }
{ for any possible damage done due to the use of this code.                     }
{ The component can be freely used in any application. The complete             }
{ source code remains property of the author and may not be distributed,        }
{ published, given or sold in any form as such. No parts of the source          }
{ code can be included in any other component or application without            }
{ written authorization of the author.                                          }
{                                                                               }
{*******************************************************************************}
unit uFDCustomQueryHelper;

interface

uses
  FireDAC.Comp.Client;

type
  TFDCustomQueryHelper = class helper for TFDCustomQuery

  public
    procedure ReturnToPool;
  end;

implementation

{ TFDCustomQueryHelper }

procedure TFDCustomQueryHelper.ReturnToPool;
begin
  // this reads really strange, but it is supposed to work.
  self.Connection.Free;
  self.Free;
end;

end.
